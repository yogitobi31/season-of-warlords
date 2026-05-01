#!/usr/bin/env python3
"""Generate temporary CastleHub pixel-art placeholder assets.

Prefers Pillow when available; falls back to a tiny pure-Python PNG writer.
"""

from __future__ import annotations

import os
import struct
import zlib
from pathlib import Path

try:
    from PIL import Image, ImageDraw  # type: ignore
except Exception:  # Pillow may not be installed.
    Image = None
    ImageDraw = None


TRANSPARENT = (0, 0, 0, 0)


def _rect(pixels: list[list[tuple[int, int, int, int]]], x: int, y: int, w: int, h: int, color: tuple[int, int, int, int]) -> None:
    height = len(pixels)
    width = len(pixels[0]) if height else 0
    for yy in range(max(0, y), min(height, y + h)):
        row = pixels[yy]
        for xx in range(max(0, x), min(width, x + w)):
            row[xx] = color


def _new_canvas(width: int, height: int, color: tuple[int, int, int, int] = TRANSPARENT) -> list[list[tuple[int, int, int, int]]]:
    return [[color for _ in range(width)] for _ in range(height)]


def _draw_character(name: str) -> tuple[int, int, list[list[tuple[int, int, int, int]]]]:
    width, height = 48, 64
    px = _new_canvas(width, height)

    palettes = {
        "leon": ((248, 220, 180, 255), (70, 110, 220, 255), (40, 60, 130, 255)),
        "garon": ((230, 190, 150, 255), (150, 70, 50, 255), (90, 40, 30, 255)),
        "elin": ((245, 210, 190, 255), (65, 170, 100, 255), (40, 110, 70, 255)),
        "mira": ((240, 200, 190, 255), (130, 90, 180, 255), (85, 60, 120, 255)),
    }
    skin, main, dark = palettes[name]

    _rect(px, 18, 8, 12, 10, skin)
    _rect(px, 16, 6, 16, 4, dark)  # hair band
    _rect(px, 19, 11, 2, 2, (20, 20, 20, 255))
    _rect(px, 27, 11, 2, 2, (20, 20, 20, 255))

    _rect(px, 14, 20, 20, 18, main)  # torso
    _rect(px, 10, 22, 4, 14, dark)  # left arm
    _rect(px, 34, 22, 4, 14, dark)  # right arm
    _rect(px, 16, 38, 7, 18, dark)  # left leg
    _rect(px, 25, 38, 7, 18, dark)  # right leg
    _rect(px, 14, 56, 10, 4, (40, 40, 40, 255))
    _rect(px, 24, 56, 10, 4, (40, 40, 40, 255))

    return width, height, px


def _draw_object(name: str) -> tuple[int, int, list[list[tuple[int, int, int, int]]]]:
    if name == "castle_gate":
        width, height = 96, 96
    else:
        width, height = 48, 48
    px = _new_canvas(width, height)

    if name == "rumor_board":
        _rect(px, 8, 10, 32, 24, (136, 92, 60, 255))
        _rect(px, 10, 12, 28, 20, (170, 126, 90, 255))
        _rect(px, 14, 16, 8, 6, (250, 240, 190, 255))
        _rect(px, 24, 16, 12, 10, (230, 220, 170, 255))
        _rect(px, 14, 34, 4, 10, (110, 80, 50, 255))
        _rect(px, 30, 34, 4, 10, (110, 80, 50, 255))
    elif name == "training_dummy":
        _rect(px, 20, 8, 8, 18, (170, 120, 70, 255))
        _rect(px, 14, 16, 20, 10, (190, 140, 80, 255))
        _rect(px, 20, 26, 8, 14, (130, 90, 55, 255))
        _rect(px, 12, 38, 24, 4, (90, 70, 50, 255))
    elif name == "castle_gate":
        _rect(px, 6, 6, 84, 84, (110, 110, 125, 255))
        _rect(px, 14, 14, 68, 76, (130, 130, 148, 255))
        _rect(px, 28, 36, 40, 54, (95, 72, 52, 255))
        _rect(px, 46, 56, 4, 8, (220, 180, 80, 255))
    elif name == "management_desk":
        _rect(px, 6, 18, 36, 18, (122, 83, 54, 255))
        _rect(px, 4, 16, 40, 4, (156, 108, 72, 255))
        _rect(px, 10, 34, 6, 10, (95, 60, 35, 255))
        _rect(px, 32, 34, 6, 10, (95, 60, 35, 255))
    elif name == "banner_blue":
        _rect(px, 8, 6, 4, 38, (120, 95, 70, 255))
        _rect(px, 12, 8, 24, 26, (60, 110, 220, 255))
        _rect(px, 20, 14, 8, 10, (230, 240, 255, 255))
    elif name == "crate_small":
        _rect(px, 10, 12, 28, 28, (150, 104, 66, 255))
        _rect(px, 12, 14, 24, 24, (170, 122, 80, 255))
        _rect(px, 22, 14, 4, 24, (120, 84, 54, 255))
        _rect(px, 12, 24, 24, 4, (120, 84, 54, 255))

    return width, height, px


def _draw_tile(name: str) -> tuple[int, int, list[list[tuple[int, int, int, int]]]]:
    width, height = 32, 32
    px = _new_canvas(width, height, (255, 255, 255, 255))

    if name == "courtyard_ground_tile":
        _rect(px, 0, 0, 32, 32, (110, 100, 86, 255))
        for y in range(0, 32, 8):
            _rect(px, 0, y, 32, 1, (130, 120, 104, 255))
        for x in range(0, 32, 8):
            _rect(px, x, 0, 1, 32, (90, 82, 70, 255))
    elif name == "castle_wall_tile":
        _rect(px, 0, 0, 32, 32, (128, 128, 140, 255))
        for y in [7, 15, 23]:
            _rect(px, 0, y, 32, 1, (92, 92, 102, 255))
        for x in [0, 10, 20, 30]:
            _rect(px, x, 0, 1, 32, (150, 150, 162, 255))
    elif name == "stone_trim_tile":
        _rect(px, 0, 0, 32, 32, (98, 98, 108, 255))
        _rect(px, 0, 0, 32, 4, (152, 152, 166, 255))
        _rect(px, 0, 28, 32, 4, (72, 72, 80, 255))
        _rect(px, 0, 14, 32, 4, (120, 120, 132, 255))

    return width, height, px


def _png_chunk(chunk_type: bytes, data: bytes) -> bytes:
    return struct.pack("!I", len(data)) + chunk_type + data + struct.pack("!I", zlib.crc32(chunk_type + data) & 0xFFFFFFFF)


def _save_png_raw(path: Path, width: int, height: int, pixels: list[list[tuple[int, int, int, int]]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for r, g, b, a in row:
            raw.extend([r, g, b, a])
    ihdr = struct.pack("!IIBBBBB", width, height, 8, 6, 0, 0, 0)
    idat = zlib.compress(bytes(raw), level=9)
    png = b"\x89PNG\r\n\x1a\n" + _png_chunk(b"IHDR", ihdr) + _png_chunk(b"IDAT", idat) + _png_chunk(b"IEND", b"")
    path.write_bytes(png)


def _save_png(path: Path, width: int, height: int, pixels: list[list[tuple[int, int, int, int]]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if Image is not None:
        image = Image.new("RGBA", (width, height), TRANSPARENT)
        draw = ImageDraw.Draw(image)
        for y, row in enumerate(pixels):
            for x, color in enumerate(row):
                if color[3]:
                    draw.point((x, y), fill=color)
        image.save(path, "PNG")
    else:
        _save_png_raw(path, width, height, pixels)


def main() -> None:
    root = Path(__file__).resolve().parents[1]

    targets: dict[str, tuple[int, int, list[list[tuple[int, int, int, int]]]]] = {}

    for c in ["leon", "garon", "elin", "mira"]:
        targets[f"assets/pixel/castlehub/characters/{c}_idle.png"] = _draw_character(c)

    for o in ["rumor_board", "training_dummy", "castle_gate", "management_desk", "banner_blue", "crate_small"]:
        targets[f"assets/pixel/castlehub/objects/{o}.png"] = _draw_object(o)

    for t in ["courtyard_ground_tile", "castle_wall_tile", "stone_trim_tile"]:
        targets[f"assets/pixel/castlehub/tiles/{t}.png"] = _draw_tile(t)

    generated: list[str] = []
    for rel_path, (w, h, px) in targets.items():
        out = root / rel_path
        _save_png(out, w, h, px)
        generated.append(rel_path)

    print("Generated temporary CastleHub assets:")
    for path in generated:
        print(path)


if __name__ == "__main__":
    main()
