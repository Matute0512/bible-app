"""Generates the app launcher icon assets for flutter_launcher_icons.

Draws a minimalist open book (white) on the Material 3 primary color
(indigo 0xFF5C6BC0). Outputs two 1024x1024 PNGs:

  assets/icon/app_icon.png          full-bleed: indigo background + white book
  assets/icon/foreground_icon.png   transparent background + white book (safe zone)

Run from the project root:  python tool/generate_icon.py
Requires: Pillow (pip install Pillow)
"""

import os

from PIL import Image, ImageDraw

SIZE = 1024
INDIGO = (0x5C, 0x6B, 0xC0, 255)
WHITE = (255, 255, 255, 255)


def quad_curve(p0, p1, p2, steps=48):
    """Samples a quadratic bezier from p0 to p2 with control point p1."""
    points = []
    for i in range(steps + 1):
        t = i / steps
        u = 1 - t
        x = u * u * p0[0] + 2 * u * t * p1[0] + t * t * p2[0]
        y = u * u * p0[1] + 2 * u * t * p1[1] + t * t * p2[1]
        points.append((x, y))
    return points


def book_contours():
    """Returns left and right page polygon point lists forming an open book."""
    spine_top = (512, 366)
    spine_bottom = (512, 646)

    # Left page: outer top edge drops from the spine, outer side is slightly
    # curved, bottom edge sags gently (pages curl outward when open).
    left_top = (300, 434)
    left_bottom = (316, 686)
    left_outer = quad_curve(left_top, (270, 560), left_bottom)
    left_bottom_edge = quad_curve(left_bottom, (414, 700), spine_bottom)

    left = [spine_top, *left_outer, *left_bottom_edge]
    left = [left[0], *left_outer, *left_bottom_edge]

    # Right page: mirror of the left page around x = 512.
    def mirror(pts):
        return [(2 * 512 - x, y) for (x, y) in pts]

    right = mirror(left)
    return [left, right]


def draw_book(draw, offset=(0, 0)):
    """Fills the open book polygons with white on the given draw context."""
    ox, oy = offset
    for contour in book_contours():
        shifted = [(x + ox, y + oy) for (x, y) in contour]
        draw.polygon(shifted, fill=WHITE)


def main():
    out_dir = os.path.join("assets", "icon")
    os.makedirs(out_dir, exist_ok=True)

    # Legacy / general icon: full indigo background.
    img = Image.new("RGBA", (SIZE, SIZE), INDIGO)
    draw_book(ImageDraw.Draw(img))
    legacy = os.path.join(out_dir, "app_icon.png")
    img.save(legacy)
    print(f"Wrote {legacy}")

    # Adaptive foreground: transparent background, book within the safe zone.
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw_book(ImageDraw.Draw(fg))
    foreground = os.path.join(out_dir, "foreground_icon.png")
    fg.save(foreground)
    print(f"Wrote {foreground}")


if __name__ == "__main__":
    main()
