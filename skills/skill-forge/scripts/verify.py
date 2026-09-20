#!/usr/bin/env python3
"""skill-forge gate engine: read the sibling file-types.json, group by suffix, fix and re-verify.

Usage: python verify.py [--list] <file-or-dir>...
Exit codes: 0 = all clean; 1 = residual problems; 2 = the gate itself or the rules table failed.
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
    """The gate itself or the rules table cannot continue: missing tool, bad path, malformed rules."""


@dataclass(frozen=True)
class ToolSpec:
    """Constraints on one external tool, declared in the rules table to catch bad config early."""

    name: str
    suffixes: frozenset[str] = frozenset()
    no_target_markers: tuple[str, ...] = ()


@dataclass(frozen=True)
class BuiltinSpec:
    """Reference to a builtin checker; when only is non-empty it applies only to those names."""

    check: str
    only: frozenset[str] = frozenset()


@dataclass(frozen=True)
class TypeRule:
    """The full pipeline for one file type."""

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
        description="skill-forge gate: fix and re-verify skill files using file-types.json.",
    )
    parser.add_argument("paths", nargs="*", help="files or directories to check")
    parser.add_argument(
        "--list",
        action="store_true",
        help="print the rules table and tool availability, then exit",
    )
    return parser.parse_args(argv)


def _as_str_tuple(value: object, where: str) -> tuple[str, ...]:
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise GateError(f"rules table {where} must be an array of strings")
    return tuple(value)


def _as_list(value: object, where: str) -> list[object]:
    if not isinstance(value, list):
        raise GateError(f"rules table {where} must be an array")
    return list(value)


def _as_dict(value: object, where: str) -> dict[str, object]:
    if not isinstance(value, dict):
        raise GateError(f"rules table {where} must be an object")
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
            raise GateError(f"rules table {where}.builtins[{index}] is missing check")
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
            raise GateError(f"rules table {where}[{index}] is an empty command")
        steps.append(step)
    return tuple(steps)


def _check_tool_fit(rule: TypeRule, tools: dict[str, ToolSpec]) -> None:
    """Catch the misconfiguration where files are handed to a tool that does not accept them."""
    for step in (*rule.fix, *rule.verify):
        spec = tools.get(step[0])
        if spec is None or not spec.suffixes:
            continue
        wrong = sorted(rule.suffixes - spec.suffixes)
        if wrong:
            allowed = ", ".join(sorted(spec.suffixes))
            raise GateError(
                f"rules table misconfigured: {rule.id} hands "
                f"{', '.join(wrong)} to {step[0]}, which only accepts {allowed}"
            )


def load_rules(
    path: Path,
) -> tuple[list[TypeRule], dict[str, ToolSpec], tuple[BuiltinSpec, ...]]:
    try:
        raw: object = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        raise GateError(f"cannot read the rules table: {exc}") from exc
    root = _as_dict(raw, "top level")
    tools = _parse_tools(root.get("tools"))
    package_checks = _parse_builtins(root.get("package_checks"), "package_checks")
    rules: list[TypeRule] = []
    owner: dict[str, str] = {}
    for index, item in enumerate(_as_list(root.get("types"), "types")):
        where = f"types[{index}]"
        fields = _as_dict(item, where)
        rule_id = fields.get("id")
        if not isinstance(rule_id, str) or not rule_id:
            raise GateError(f"rules table {where} is missing id")
        suffixes = _as_str_tuple(fields.get("suffixes", []), f"{where}.suffixes")
        if not suffixes:
            raise GateError(f"rules table {where} is missing suffixes")
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
                    f"rules table suffix {suffix} is declared by both "
                    f"{owner[suffix]} and {rule_id}"
                )
            owner[suffix] = rule_id
        _check_tool_fit(rule, tools)
        rules.append(rule)
    if not rules:
        raise GateError("rules table defines no types")
    return rules, tools, package_checks


def load_checkers() -> dict[str, Checker]:
    """Load the sibling checkers.py by path, avoiding a clash with a stdlib module name."""
    spec = importlib.util.spec_from_file_location("skill_forge_checkers", CHECKERS_PATH)
    if spec is None or spec.loader is None:
        raise GateError(f"cannot load the checkers module: {CHECKERS_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    registry = getattr(module, "CHECKERS", None)
    if not isinstance(registry, dict):
        raise GateError("checkers.py does not define a CHECKERS dict")
    return {str(name): checker for name, checker in registry.items()}


def resolve_tools(names: Iterable[str]) -> dict[str, str]:
    found: dict[str, str] = {}
    for name in names:
        located = shutil.which(name)
        if located is None:
            raise GateError(
                f"missing tool {name}, not on PATH; this gate only calls system tools"
            )
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
        return 1, f"timed out (>{TIMEOUT_SECONDS}s)"
    parts = [part.strip() for part in (proc.stdout, proc.stderr) if part.strip()]
    return proc.returncode, "\n".join(parts)


def iter_files(targets: Iterable[str]) -> list[Path]:
    found: set[Path] = set()
    for raw in targets:
        path = Path(raw).resolve()
        if not path.exists():
            raise GateError(f"path does not exist: {raw}")
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


def run_checks(
    specs: Sequence[BuiltinSpec],
    files: Sequence[Path],
    checkers: dict[str, Checker],
    where: str,
) -> list[str]:
    """Run a set of builtin checks; type-level and package-level share this, differing in where."""
    problems: list[str] = []
    for spec in specs:
        checker = checkers.get(spec.check)
        if checker is None:
            raise GateError(f"{where} references unregistered checker {spec.check}")
        for path in files:
            if spec.only and path.name not in spec.only:
                continue
            problems += [f"{path}: {msg}" for msg in checker(path)]
    return problems


def collect_builtin_problems(
    rule: TypeRule, files: Sequence[Path], checkers: dict[str, Checker]
) -> list[str]:
    return run_checks(rule.builtins, files, checkers, f"rule {rule.id}")


def _savings_note(before: int, after: int) -> str:
    if before <= 0:
        return ""
    saved = (before - after) / before * 100
    return f" ({before} -> {after} bytes, {saved:.1f}% saved)"


def run_group(
    rule: TypeRule,
    files: Sequence[Path],
    tool_paths: dict[str, str],
    tool_specs: dict[str, ToolSpec],
    checkers: dict[str, Checker],
) -> tuple[list[str], list[str]]:
    """Fix and re-verify one file type: returns (residual problems, suspected rules-table errors)."""
    residual = collect_builtin_problems(rule, files, checkers)
    before = sum(path.stat().st_size for path in files) if rule.report_savings else 0
    for step in rule.fix:
        run(build_cmd(step, files))
    config_errors: list[str] = []
    for step in rule.verify:
        code, out = run(build_cmd(step, files))
        if code == 0:
            continue
        detail = _indent(out) if out else "(no output)"
        if _is_no_target(step[0], out, tool_specs):
            config_errors.append(
                f"{step[0]} did not accept these files, check the rules table:\n"
                f"{DETAIL_INDENT}{detail}"
            )
            continue
        residual.append(f"{' '.join(step)} (exit {code})\n{DETAIL_INDENT}{detail}")
    after = sum(path.stat().st_size for path in files)
    note = _savings_note(before, after) if rule.report_savings else ""
    bad = len(residual) + len(config_errors)
    status = "OK" if not bad else f"{bad} to fix"
    print(f"{rule.label}: {len(files)} file(s): {status}{note}")
    for item in config_errors:
        print(f"{INDENT}!! {item}")
    for item in residual:
        print(INDENT + item)
    return residual, config_errors


def _version_line(name: str, raw: str) -> str:
    """Normalize version banners: some tools print a bare `Version: x.y.z` without their name."""
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


def print_matrix(
    rules: Sequence[TypeRule],
    tool_specs: dict[str, ToolSpec],
    package_checks: Sequence[BuiltinSpec],
) -> None:
    print(f"Rules table: {RULES_PATH}")
    for rule in rules:
        fixers = ", ".join(dict.fromkeys(step[0] for step in rule.fix)) or "none"
        verifiers = ", ".join(dict.fromkeys(step[0] for step in rule.verify)) or "none"
        checks = ", ".join(spec.check for spec in rule.builtins) or "none"
        print(f"  {rule.id:<12} {' '.join(sorted(rule.suffixes))}")
        print(f"      fix {fixers} / verify {verifiers} / builtin {checks}")
    package_line = ", ".join(spec.check for spec in package_checks) or "none"
    print(f"  {'package':<12} (all files)")
    print(f"      builtin {package_line}")
    declared = sorted(tool_specs)
    missing = [name for name in declared if shutil.which(name) is None]
    print(f"Tools: {', '.join(declared) or 'none'}")
    if missing:
        print(
            f"Missing tools: {', '.join(missing)} (any that are used will fail outright)"
        )


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
    package_problems: list[str] = []
    try:
        args = parse_args(argv)
        rules, tool_specs, package_checks = load_rules(RULES_PATH)
        if args.list:
            print_matrix(rules, tool_specs, package_checks)
            return 0
        if not args.paths:
            print(
                "Give files or directories to check; use --list to see the rules table."
            )
            return 2
        checkers = load_checkers()
        files = iter_files(args.paths)
        if not files:
            print(f"No checkable files found: {' '.join(args.paths)}")
            return 2
        package_problems = run_checks(package_checks, files, checkers, "package_checks")
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
        print(f"Gate cannot run: {exc}")
        return 2

    print(f"Tools: {tool_banner(tool_paths, needed)}")
    if package_problems:
        print(f"Package checks: {len(package_problems)} to fix")
        for item in package_problems:
            print(INDENT + item)
    residual: list[str] = list(package_problems)
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
        shown = ", ".join(suffix or "(no suffix)" for suffix in uncovered)
        print(
            f"Suffixes outside the gate: {shown} "
            "(add a block in file-types.json to cover them)"
        )
    if config_errors:
        print(f"Rules table has problems: {len(config_errors)}")
        return 2
    if residual:
        print(f"Gate failed: {len(residual)} to fix")
        return 1
    print(f"Gate passed: all {len(files)} files clean")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
