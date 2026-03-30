from __future__ import annotations

from pathlib import Path
import os
import sys
import tempfile

from application.better_search.replacements import BETTER_SEARCH_REPLACEMENTS, ReplacementFile


def _detect_encoding(raw_bytes: bytes) -> str | None:
    if raw_bytes.startswith(b"\xef\xbb\xbf"):
        return "utf-8-sig"
    if raw_bytes.startswith(b"\xff\xfe"):
        return "utf-16"
    if raw_bytes.startswith(b"\xfe\xff"):
        return "utf-16-be"

    null_even = raw_bytes[0::2].count(0)
    null_odd = raw_bytes[1::2].count(0)
    utf16_threshold = max(len(raw_bytes) // 4, 1)

    if null_odd >= utf16_threshold:
        return "utf-16-le"
    if null_even >= utf16_threshold:
        return "utf-16-be"

    return None


def _read_template_text(path: Path) -> str:
    raw_bytes = path.read_bytes()
    detected_encoding = _detect_encoding(raw_bytes)
    encoding = detected_encoding or "utf-8"
    text = raw_bytes.decode(encoding)
    return text.replace("\r\n", "\n").replace("\r", "\n")


def _resolve_target_encoding(path: Path, replacement: ReplacementFile) -> str:
    raw_bytes = path.read_bytes()
    detected_encoding = _detect_encoding(raw_bytes)

    if detected_encoding in {"utf-16", "utf-16-le", "utf-16-be"}:
        return detected_encoding

    return replacement.target_encoding


def _write_text_atomic(path: Path, content: str, encoding: str) -> None:
    fd, temp_path = tempfile.mkstemp(
        dir=path.parent,
        prefix=f"{path.stem}_",
        suffix=".tmp",
    )

    try:
        with os.fdopen(fd, "w", encoding=encoding, newline="\r\n") as file:
            file.write(content)
            file.flush()
            os.fsync(file.fileno())

        os.replace(temp_path, path)
    except Exception:
        try:
            os.remove(temp_path)
        except FileNotFoundError:
            pass
        raise


def run_better_search(game_path: str | None) -> bool:
    if not game_path or not game_path.strip():
        print("[BetterSearch] Game path was not provided.", file=sys.stderr)
        return False

    game_root = Path(game_path).expanduser()
    if not game_root.is_dir():
        print(
            f"[BetterSearch] Invalid game path: {game_root}",
            file=sys.stderr,
        )
        return False

    try:
        for relative_target_path, replacement in BETTER_SEARCH_REPLACEMENTS.items():
            target_path = game_root / relative_target_path
            if not target_path.is_file():
                print(
                    f"[BetterSearch] Target file not found: {target_path}",
                    file=sys.stderr,
                )
                return False

            if not replacement.template_path.is_file():
                print(
                    f"[BetterSearch] Template file not found: {replacement.template_path}",
                    file=sys.stderr,
                )
                return False

            template_text = _read_template_text(replacement.template_path)
            target_encoding = _resolve_target_encoding(target_path, replacement)
            _write_text_atomic(target_path, template_text, target_encoding)

        return True
    except Exception as exc:
        print(f"[BetterSearch] Failed to apply replacements: {exc}", file=sys.stderr)
        return False
