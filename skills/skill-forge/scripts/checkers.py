"""skill-forge builtin checkers: the validations that do not go through an external tool.

Each checker has the signature `(path: Path) -> list[str]`, returns problem descriptions,
and an empty list means it passed. Reference one in `file-types.json` with
`{"check": "name"}`; `{"check": "name", "only": ["SKILL.md"]}` limits it to those file names.

To extend: add a function here and register it in `CHECKERS`; the engine needs no change.
"""

from __future__ import annotations

import json
import os
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
        return "", [f"cannot read as UTF-8: {exc}"]


def python_syntax(path: Path) -> list[str]:
    """Compile the source once to catch syntax-level errors; the cheapest regression net."""
    source, problems = _read_text(path)
    if problems:
        return problems
    try:
        compile(source, str(path), "exec")
    except (SyntaxError, ValueError) as exc:
        return [f"syntax compile failed: {exc}"]
    return []


def json_parse(path: Path) -> list[str]:
    """Confirm the file parses as JSON, catching hand-written syntax errors in data files."""
    source, problems = _read_text(path)
    if problems:
        return problems
    try:
        json.loads(source)
    except (json.JSONDecodeError, ValueError) as exc:
        return [f"JSON does not parse: {exc}"]
    return []


def skill_frontmatter(path: Path) -> list[str]:
    """Check the frontmatter is complete and name equals the directory name; else it will not load."""
    if path.name != "SKILL.md":
        return []
    source, problems = _read_text(path)
    if problems:
        return problems
    if not source.startswith("---"):
        return ["frontmatter missing"]
    end = source.find(FRONTMATTER_END, 3)
    if end == -1:
        return ["frontmatter not closed"]
    block = source[3:end]
    found: list[str] = []
    match = NAME_RE.search(block)
    if match is None:
        found.append("frontmatter is missing name")
    else:
        name = match.group(1).strip().strip("\"'")
        if name != path.parent.name:
            found.append(
                f"frontmatter name={name!r} does not match "
                f"directory name {path.parent.name!r}"
            )
    if DESC_RE.search(block) is None:
        found.append("frontmatter is missing description")
    return found


def _walk_png_chunks(data: bytes, found: list[str], seen: set[bytes]) -> int:
    """Walk the PNG chunk by chunk, returning the end offset and recording structural problems."""
    check_crc = len(data) <= PNG_CRC_LIMIT
    offset = len(PNG_SIGNATURE)
    while offset + 8 <= len(data):
        length, tag = struct.unpack(">I4s", data[offset : offset + 8])
        body_start = offset + 8
        body_end = body_start + length
        if body_end + 4 > len(data):
            found.append(f"chunk {tag!r} declares length {length} past end of file")
            return offset
        seen.add(tag)
        if tag == b"IHDR":
            if length != IHDR_LENGTH:
                found.append(f"IHDR length should be {IHDR_LENGTH}, got {length}")
            else:
                width, height = struct.unpack(">II", data[body_start : body_start + 8])
                if width == 0 or height == 0:
                    found.append(f"IHDR has invalid dimensions: {width}x{height}")
        if check_crc:
            expected = struct.unpack(">I", data[body_end : body_end + 4])[0]
            actual = zlib.crc32(data[offset + 4 : body_end]) & 0xFFFFFFFF
            if expected != actual:
                found.append(f"chunk {tag!r} CRC mismatch")
        offset = body_end + 4
        if tag == b"IEND":
            break
    return offset


def png_integrity(path: Path) -> list[str]:
    """oxipng rewrites the binary in place; re-check chunk structure and CRCs to confirm it held."""
    try:
        data = path.read_bytes()
    except OSError as exc:
        return [f"cannot read: {exc}"]
    if not data.startswith(PNG_SIGNATURE):
        return ["not a PNG: signature mismatch"]
    found: list[str] = []
    seen: set[bytes] = set()
    offset = _walk_png_chunks(data, found, seen)
    if b"IHDR" not in seen:
        found.append("missing IHDR")
    if b"IEND" not in seen:
        found.append("missing IEND")
    elif offset != len(data):
        found.append(f"{len(data) - offset} extra bytes after IEND")
    return found


def _home_needles() -> tuple[str, ...]:
    """The spellings of this machine's home directory, used to spot hard-coded local paths.

    Only the home directory that really exists on this machine is used, so an
    illustrative `C:/Users/someone` in documentation never triggers a false positive.
    Anything shorter than 4 characters (such as `C:/`) is dropped, so a whole drive
    never becomes a match pattern.
    """
    candidates = {str(Path.home())}
    for var in ("USERPROFILE", "HOME"):
        value = os.environ.get(var)
        if value:
            candidates.add(value)
    needles: list[str] = []
    for item in sorted(candidates):
        for form in (item, item.replace("\\", "/")):
            if len(form) > 3 and form not in needles:
                needles.append(form)
    return tuple(needles)


def no_local_paths(path: Path) -> list[str]:
    """A skill package must not carry this machine's absolute paths: elsewhere that text is wrong.

    Binary files are skipped silently; portability is not their concern, so a decode
    failure is not counted as a problem.
    """
    try:
        source = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return []
    lowered = source.lower()
    for needle in _home_needles():
        if needle.lower() in lowered:
            return [
                (
                    f"found this machine's absolute path {needle}; a skill package gets "
                    "copied to other machines and paths, where a hard-coded path is simply "
                    "wrong -- use ~ or the <this skill dir> placeholder instead"
                )
            ]
    return []


CHECKERS: dict[str, Checker] = {
    "python-syntax": python_syntax,
    "json-parse": json_parse,
    "skill-frontmatter": skill_frontmatter,
    "png-integrity": png_integrity,
    "no-local-paths": no_local_paths,
}
