#!/usr/bin/env python3
"""skill-forge 闸门引擎：读同目录的 file-types.json，按后缀分组跑修复与复验。

用法: python verify.py [--list] <文件或目录>...
退出码: 0 = 全部干净；1 = 有残余问题；2 = 闸门自身或规则表出错。
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
import subprocess
import sys
from collections.abc import Callable, Iterable, Sequence
from dataclasses import dataclass
from pathlib import Path

SKIP_PARTS = {
    "__pycache__",
    ".git",
    ".venv",
    "venv",
    "node_modules",
    ".ruff_cache",
    ".rumdl_cache",
    ".ty_cache",
    ".mypy_cache",
    ".pytest_cache",
}
TIMEOUT_SECONDS = 300
INDENT = "    "
DETAIL_INDENT = INDENT * 2
SCRIPT_DIR = Path(__file__).resolve().parent
RULES_PATH = SCRIPT_DIR / "file-types.json"
CHECKERS_PATH = SCRIPT_DIR / "checkers.py"
Checker = Callable[[Path], list[str]]


class GateError(Exception):
    """闸门自身或规则表无法继续：工具缺失、路径不存在、规则表写错。"""


@dataclass(frozen=True)
class ToolSpec:
    """规则表里对某个外部工具的约束，用于提前拦住配置错误。"""

    name: str
    suffixes: frozenset[str] = frozenset()
    no_target_markers: tuple[str, ...] = ()


@dataclass(frozen=True)
class BuiltinSpec:
    """对内置检查器的引用；only 非空时只对列出的文件名生效。"""

    check: str
    only: frozenset[str] = frozenset()


@dataclass(frozen=True)
class TypeRule:
    """一种文件类型的完整流水线。"""

    id: str
    label: str
    suffixes: frozenset[str]
    builtins: tuple[BuiltinSpec, ...] = ()
    fix: tuple[tuple[str, ...], ...] = ()
    verify: tuple[tuple[str, ...], ...] = ()
    report_savings: bool = False


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="verify.py",
        description="skill-forge 闸门：按 file-types.json 的规则修复并复验包内文件。",
    )
    parser.add_argument("paths", nargs="*", help="要检查的文件或目录")
    parser.add_argument(
        "--list", action="store_true", help="打印规则表与工具可用性后退出"
    )
    return parser.parse_args(argv)


def _as_str_tuple(value: object, where: str) -> tuple[str, ...]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise GateError(f"规则表 {where} 应为字符串数组")
    return tuple(value)


def _as_list(value: object, where: str) -> list[object]:
    if not isinstance(value, list):
        raise GateError(f"规则表 {where} 应为数组")
    return list(value)


def _as_dict(value: object, where: str) -> dict[str, object]:
    if not isinstance(value, dict):
        raise GateError(f"规则表 {where} 应为对象")
    return {str(key): item for key, item in value.items()}


def _parse_tools(raw: object) -> dict[str, ToolSpec]:
    specs: dict[str, ToolSpec] = {}
    for name, cfg in _as_dict(raw if raw is not None else {}, "tools").items():
        fields = _as_dict(cfg, f"tools.{name}")
        specs[name] = ToolSpec(
            name=name,
            suffixes=frozenset(
                _as_str_tuple(fields.get("suffixes", []), f"tools.{name}.suffixes")
            ),
            no_target_markers=_as_str_tuple(
                fields.get("no_target_markers", []),
                f"tools.{name}.no_target_markers",
            ),
        )
    return specs


def _parse_builtins(raw: object, where: str) -> tuple[BuiltinSpec, ...]:
    specs: list[BuiltinSpec] = []
    for index, item in enumerate(
        _as_list(raw if raw is not None else [], f"{where}.builtins")
    ):
        fields = _as_dict(item, f"{where}.builtins[{index}]")
        check = fields.get("check")
        if not isinstance(check, str) or not check:
            raise GateError(f"规则表 {where}.builtins[{index}] 缺 check")
        specs.append(
            BuiltinSpec(
                check=check,
                only=frozenset(
                    _as_str_tuple(
                        fields.get("only", []), f"{where}.builtins[{index}].only"
                    )
                ),
            )
        )
    return tuple(specs)


def _parse_steps(raw: object, where: str) -> tuple[tuple[str, ...], ...]:
    steps: list[tuple[str, ...]] = []
    for index, item in enumerate(_as_list(raw if raw is not None else [], where)):
        step = _as_str_tuple(item, f"{where}[{index}]")
        if not step:
            raise GateError(f"规则表 {where}[{index}] 是空命令")
        steps.append(step)
    return tuple(steps)


def _check_tool_fit(rule: TypeRule, tools: dict[str, ToolSpec]) -> None:
    """拦住「把文件交给不认它的工具」这类配置错误。"""
    for step in (*rule.fix, *rule.verify):
        spec = tools.get(step[0])
        if spec is None or not spec.suffixes:
            continue
        wrong = sorted(rule.suffixes - spec.suffixes)
        if wrong:
            allowed = "、".join(sorted(spec.suffixes))
            raise GateError(
                f"规则表配置错误：{rule.id} 把 {'、'.join(wrong)} 交给 {step[0]}，"
                f"但该工具只接受 {allowed}"
            )


def load_rules(path: Path) -> tuple[list[TypeRule], dict[str, ToolSpec]]:
    try:
        raw: object = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        raise GateError(f"规则表读取失败：{exc}") from exc
    root = _as_dict(raw, "顶层")
    tools = _parse_tools(root.get("tools"))
    rules: list[TypeRule] = []
    owner: dict[str, str] = {}
    for index, item in enumerate(_as_list(root.get("types"), "types")):
        where = f"types[{index}]"
        fields = _as_dict(item, where)
        rule_id = fields.get("id")
        if not isinstance(rule_id, str) or not rule_id:
            raise GateError(f"规则表 {where} 缺 id")
        suffixes = _as_str_tuple(fields.get("suffixes", []), f"{where}.suffixes")
        if not suffixes:
            raise GateError(f"规则表 {where} 缺 suffixes")
        rule = TypeRule(
            id=rule_id,
            label=str(fields.get("label", rule_id)),
            suffixes=frozenset(suffixes),
            builtins=_parse_builtins(fields.get("builtins"), where),
            fix=_parse_steps(fields.get("fix"), f"{where}.fix"),
            verify=_parse_steps(fields.get("verify"), f"{where}.verify"),
            report_savings=bool(fields.get("report_savings", False)),
        )
        for suffix in sorted(rule.suffixes):
            if suffix in owner:
                raise GateError(
                    f"规则表后缀 {suffix} 被 {owner[suffix]} 与 {rule_id} 重复声明"
                )
            owner[suffix] = rule_id
        _check_tool_fit(rule, tools)
        rules.append(rule)
    if not rules:
        raise GateError("规则表没有任何 types")
    return rules, tools


def load_checkers() -> dict[str, Checker]:
    """按路径加载同目录的 checkers.py，避免与标准库模块重名。"""
    spec = importlib.util.spec_from_file_location("skill_forge_checkers", CHECKERS_PATH)
    if spec is None or spec.loader is None:
        raise GateError(f"无法加载检查器模块：{CHECKERS_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    registry = getattr(module, "CHECKERS", None)
    if not isinstance(registry, dict):
        raise GateError("checkers.py 未定义 CHECKERS 字典")
    return {str(name): checker for name, checker in registry.items()}


def resolve_tools(names: Iterable[str]) -> dict[str, str]:
    found: dict[str, str] = {}
    for name in names:
        located = shutil.which(name)
        if located is None:
            raise GateError(f"缺少工具 {name}，不在 PATH 上；本闸门只调用系统工具")
        found[name] = located
    return found


def run(cmd: Sequence[str]) -> tuple[int, str]:
    try:
        proc = subprocess.run(
            list(cmd),
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=TIMEOUT_SECONDS,
            check=False,
        )
    except subprocess.TimeoutExpired:
        return 1, f"超时（>{TIMEOUT_SECONDS}s）"
    parts = [part.strip() for part in (proc.stdout, proc.stderr) if part.strip()]
    return proc.returncode, "\n".join(parts)


def iter_files(targets: Iterable[str]) -> list[Path]:
    found: set[Path] = set()
    for raw in targets:
        path = Path(raw).resolve()
        if not path.exists():
            raise GateError(f"路径不存在：{raw}")
        candidates = path.rglob("*") if path.is_dir() else [path]
        for item in candidates:
            if item.is_file() and not SKIP_PARTS & set(item.parts):
                found.add(item)
    return sorted(found)


def build_cmd(step: Sequence[str], files: Sequence[Path]) -> list[str]:
    return [*step, *[str(path) for path in files]]


def _indent(text: str) -> str:
    return text.replace("\n", "\n" + DETAIL_INDENT)


def _is_no_target(tool: str, out: str, tools: dict[str, ToolSpec]) -> bool:
    spec = tools.get(tool)
    return spec is not None and any(marker in out for marker in spec.no_target_markers)


def collect_builtin_problems(
    rule: TypeRule, files: Sequence[Path], checkers: dict[str, Checker]
) -> list[str]:
    problems: list[str] = []
    for spec in rule.builtins:
        checker = checkers.get(spec.check)
        if checker is None:
            raise GateError(f"规则 {rule.id} 引用了未注册的检查器 {spec.check}")
        for path in files:
            if spec.only and path.name not in spec.only:
                continue
            problems += [f"{path}: {msg}" for msg in checker(path)]
    return problems


def _savings_note(before: int, after: int) -> str:
    if before <= 0:
        return ""
    return f"（{before} → {after} 字节，省 {(before - after) / before * 100:.1f}%）"


def run_group(
    rule: TypeRule,
    files: Sequence[Path],
    tool_paths: dict[str, str],
    tool_specs: dict[str, ToolSpec],
    checkers: dict[str, Checker],
) -> tuple[list[str], list[str]]:
    """跑一种类型的修复与复验，返回（残余问题, 规则表疑似配置错误）。"""
    residual = collect_builtin_problems(rule, files, checkers)
    before = sum(path.stat().st_size for path in files) if rule.report_savings else 0
    for step in rule.fix:
        run(build_cmd(step, files))
    config_errors: list[str] = []
    for step in rule.verify:
        code, out = run(build_cmd(step, files))
        if code == 0:
            continue
        detail = _indent(out) if out else "无输出"
        if _is_no_target(step[0], out, tool_specs):
            config_errors.append(
                f"{step[0]} 没有接受这些文件，检查规则表：\n{DETAIL_INDENT}{detail}"
            )
            continue
        residual.append(f"{' '.join(step)} (exit {code})\n{DETAIL_INDENT}{detail}")
    after = sum(path.stat().st_size for path in files)
    note = _savings_note(before, after) if rule.report_savings else ""
    bad = len(residual) + len(config_errors)
    print(
        f"{rule.label}: {len(files)} 个文件: {'OK' if not bad else f'{bad} 项待修'}{note}"
    )
    for item in config_errors:
        print(f"{INDENT}!! {item}")
    for item in residual:
        print(INDENT + item)
    return residual, config_errors


def _version_line(name: str, raw: str) -> str:
    """统一版本横幅：有的工具只打印 `Version: x.y.z`，不带自己的名字。"""
    line = raw.splitlines()[0] if raw else ""
    head, sep, tail = line.partition(":")
    if sep and head.strip().lower() in {"version", name.lower()}:
        line = tail.strip()
    return line if line.lower().startswith(name.lower()) else f"{name} {line}".strip()


def tool_banner(tool_paths: dict[str, str], names: Iterable[str]) -> str:
    parts: list[str] = []
    for name in names:
        _, out = run([tool_paths[name], "--version"])
        parts.append(_version_line(name, out))
    return "  ".join(parts)


def print_matrix(rules: Sequence[TypeRule], tool_specs: dict[str, ToolSpec]) -> None:
    print(f"规则表：{RULES_PATH}")
    for rule in rules:
        fixers = "、".join(dict.fromkeys(step[0] for step in rule.fix)) or "无"
        verifiers = "、".join(dict.fromkeys(step[0] for step in rule.verify)) or "无"
        checks = "、".join(spec.check for spec in rule.builtins) or "无"
        print(f"  {rule.id:<12} {' '.join(sorted(rule.suffixes))}")
        print(f"      修复 {fixers}／复验 {verifiers}／内置 {checks}")
    declared = sorted(tool_specs)
    missing = [name for name in declared if shutil.which(name) is None]
    print(f"工具：{'、'.join(declared) or '无'}")
    if missing:
        print(f"缺工具：{'、'.join(missing)}（用到的那些会直接报错）")


def group_by_rule(
    rules: Sequence[TypeRule], files: Sequence[Path]
) -> list[tuple[TypeRule, list[Path]]]:
    by_suffix: dict[str, list[Path]] = {}
    for path in files:
        by_suffix.setdefault(path.suffix.lower(), []).append(path)
    return [
        (
            rule,
            sorted(
                path for suffix in rule.suffixes for path in by_suffix.get(suffix, [])
            ),
        )
        for rule in rules
    ]


def main(argv: Sequence[str]) -> int:
    try:
        args = parse_args(argv)
        rules, tool_specs = load_rules(RULES_PATH)
        if args.list:
            print_matrix(rules, tool_specs)
            return 0
        if not args.paths:
            print("需要给出要检查的文件或目录；用 --list 看规则表。")
            return 2
        checkers = load_checkers()
        files = iter_files(args.paths)
        if not files:
            print(f"未找到可检查的文件：{' '.join(args.paths)}")
            return 2
        groups = group_by_rule(rules, files)
        needed = sorted(
            {
                step[0]
                for rule, group in groups
                if group
                for step in (*rule.fix, *rule.verify)
            }
        )
        tool_paths = resolve_tools(needed)
    except GateError as exc:
        print(f"闸门无法运行：{exc}")
        return 2

    print(f"工具：{tool_banner(tool_paths, needed)}")
    residual: list[str] = []
    config_errors: list[str] = []
    for rule, group in groups:
        if not group:
            continue
        group_residual, group_config = run_group(
            rule, group, tool_paths, tool_specs, checkers
        )
        residual += group_residual
        config_errors += group_config

    covered = set().union(*(rule.suffixes for rule in rules))
    uncovered = sorted({path.suffix.lower() for path in files} - covered)
    print()
    if uncovered:
        shown = "、".join(suffix or "（无后缀）" for suffix in uncovered)
        print(f"未纳入闸门的后缀：{shown}（在 file-types.json 加一段即可覆盖）")
    if config_errors:
        print(f"规则表有问题：{len(config_errors)} 项")
        return 2
    if residual:
        print(f"闸门未通过：{len(residual)} 项待修")
        return 1
    print(f"闸门通过：{len(files)} 个文件全部干净")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
