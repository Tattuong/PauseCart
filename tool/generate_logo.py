#!/usr/bin/env python3
"""A violet shopping bag with a pause mark for the PauseCart launcher."""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SIZE = 1024
CREAM = (247, 244, 239, 255)
VIOLET = (109, 74, 255, 255)
WHITE = (255, 255, 255, 255)


def _mark(canvas: Image.Image) -> None:
    draw = ImageDraw.Draw(canvas)
    # Handle ends tuck into the bag so it reads as a tote, not a lock.
    draw.arc((390, 268, 634, 572), start=180, end=360, fill=VIOLET, width=64)
    draw.rounded_rectangle((292, 430, 732, 812), radius=88, fill=VIOLET)
    draw.rounded_rectangle((428, 520, 492, 730), radius=24, fill=WHITE)
    draw.rounded_rectangle((532, 520, 596, 730), radius=24, fill=WHITE)


def main() -> None:
    assets = ROOT / "assets"
    assets.mkdir(exist_ok=True)

    logo = Image.new("RGBA", (SIZE, SIZE), CREAM)
    _mark(logo)
    logo.convert("RGB").save(assets / "logo.png", optimize=True)

    splash = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    _mark(splash)
    splash_path = ROOT / "android/app/src/main/res/drawable-nodpi/splash_icon.png"
    splash_path.parent.mkdir(parents=True, exist_ok=True)
    splash.save(splash_path, optimize=True)
    print(f"wrote {assets / 'logo.png'}")


if __name__ == "__main__":
    main()
