"""skill-forge 内置检查器：不走外部工具的那几种校验。

每个检查器签名为 `(path: Path) -> list[str]`，返回问题描述，空列表表示通过。
在 `file-types.json` 里用 `{"check": "名字"}` 引用；`{"check": "名字", "only": ["SKILL.md"]}`
可以限定只对指定文件名生效。

扩展方式：在这里加一个函数并注册进 `CHECKERS`，无需改动引擎。
"""

from __future__ import annotations

import json
import re
import struct
import zlib
from collections.abc import Callable
from pathlib import Path

FRONTMATTER_END = "\n---"
NAME_RE = re.compile(r"^name:[ \t]*(.+?)[ \t]*$", re.MULTILINE)
DESC_RE = re.compile(r"^description:", re.MULTILINE)
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
PNG_CRC_LIMIT = 8 * 1024 * 1024
IHDR_LENGTH = 13

Checker = Callable[[Path], list[str]]


def _read_text(path: Path) -> tuple[str, list[str]]:
    try:
        return path.read_text(encoding="utf-8"), []
    except (UnicodeDecodeError, OSError) as exc:
        return "", [f"无法按 UTF-8 读取：{exc}"]


def python_syntax(path: Path) -> list[str]:
    """编译一次源码，抓语法层错误，这是最便宜的回归网。"""
    source, problems = _read_text(path)
    if problems:
        return problems
    try:
        compile(source, str(path), "exec")
    except (SyntaxError, ValueError) as exc:
        return [f"语法编译失败：{exc}"]
    return []


def json_parse(path: Path) -> list[str]:
    """确认能被 json 解析，挡掉表格/配置类文件的手写语法错。"""
    source, problems = _read_text(path)
    if problems:
        return problems
    try:
        json.loads(source)
    except (json.JSONDecodeError, ValueError) as exc:
        return [f"JSON 不可解析：{exc}"]
    return []


def skill_frontmatter(path: Path) -> list[str]:
    """校验 frontmatter 齐备，且 name 等于目录名——不等就加载不了。"""
    if path.name != "SKILL.md":
        return []
    source, problems = _read_text(path)
    if problems:
        return problems
    if not source.startswith("---"):
        return ["frontmatter 缺失"]
    end = source.find(FRONTMATTER_END, 3)
    if end == -1:
        return ["frontmatter 未闭合"]
    block = source[3:end]
    found: list[str] = []
    match = NAME_RE.search(block)
    if match is None:
        found.append("frontmatter 缺 name")
    else:
        name = match.group(1).strip().strip("\"'")
        if name != path.parent.name:
            found.append(
                f"frontmatter name={name!r} 与目录名 {path.parent.name!r} 不一致"
            )
    if DESC_RE.search(block) is None:
        found.append("frontmatter 缺 description")
    return found


def _walk_png_chunks(data: bytes, found: list[str], seen: set[bytes]) -> int:
    """按块走一遍 PNG，返回结束偏移；顺带记录块名与结构问题。"""
    check_crc = len(data) <= PNG_CRC_LIMIT
    offset = len(PNG_SIGNATURE)
    while offset + 8 <= len(data):
        length, tag = struct.unpack(">I4s", data[offset : offset + 8])
        body_start = offset + 8
        body_end = body_start + length
        if body_end + 4 > len(data):
            found.append(f"块 {tag!r} 声明长度 {length} 超出文件末尾")
            return offset
        seen.add(tag)
        if tag == b"IHDR":
            if length != IHDR_LENGTH:
                found.append(f"IHDR 长度应为 {IHDR_LENGTH}，实际 {length}")
            else:
                width, height = struct.unpack(">II", data[body_start : body_start + 8])
                if width == 0 or height == 0:
                    found.append(f"IHDR 尺寸非法：{width}x{height}")
        if check_crc:
            expected = struct.unpack(">I", data[body_end : body_end + 4])[0]
            actual = zlib.crc32(data[offset + 4 : body_end]) & 0xFFFFFFFF
            if expected != actual:
                found.append(f"块 {tag!r} CRC 不匹配")
        offset = body_end + 4
        if tag == b"IEND":
            break
    return offset


def png_integrity(path: Path) -> list[str]:
    """oxipng 是原地重写二进制，这里按块结构与 CRC 复核它没写坏。"""
    try:
        data = path.read_bytes()
    except OSError as exc:
        return [f"无法读取：{exc}"]
    if not data.startswith(PNG_SIGNATURE):
        return ["不是 PNG：签名不匹配"]
    found: list[str] = []
    seen: set[bytes] = set()
    offset = _walk_png_chunks(data, found, seen)
    if b"IHDR" not in seen:
        found.append("缺 IHDR")
    if b"IEND" not in seen:
        found.append("缺 IEND")
    elif offset != len(data):
        found.append(f"IEND 之后还有 {len(data) - offset} 字节多余数据")
    return found


CHECKERS: dict[str, Checker] = {
    "python-syntax": python_syntax,
    "json-parse": json_parse,
    "skill-frontmatter": skill_frontmatter,
    "png-integrity": png_integrity,
}
