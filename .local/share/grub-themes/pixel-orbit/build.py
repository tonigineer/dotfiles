#!/usr/bin/env python3
"""Build the "Pixel Orbit" GRUB themes.

    ./build.py                   build every variant into out/<variant>/
    ./build.py telemetry-sans    build only the named variant(s)
    ./build.py --preview         also write out/<variant>-preview*.png

Variants: telemetry, telemetry-sans (telemetry with smooth text and icons
instead of the pixel font and pixel icons) and horizon. `splash` builds the
Plymouth boot splash that follows telemetry-sans (060-bootsplash installs it).

Everything is drawn for a 2560x1440 framebuffer (GRUB_GFXMODE). theme.txt
positions are relative to the screen centre, so a bigger framebuffer shows the
same canvas centred on black instead of a broken layout.

The preview is not a screenshot: it re-implements the parts of GRUB's gfxmenu
this theme uses (9-slice boxes, menu item layout, timeout label/bar, PF2 glyph
drawing) after grub-core/gfxmenu/{gui_list,widget-box,gui_progress_bar,
gui_label}.c, and draws with the generated files themselves.
"""
import argparse
import math
import random
import re
import shutil
import struct
import subprocess
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
WALLPAPER = Path.home() / "Wallpaper/Wallhaven/pixel-earth-space.png"
PIXELON = "/usr/share/fonts/pixelon.regular.ttf"
TERMINUS = "/usr/share/fonts/misc/ter-u24b.otb"
KRYPTON = "/usr/share/fonts/OTF/MonaspaceKrypton-%s.otf"  # otf-monaspace, one file per style
NERD = "/usr/share/fonts/TTF/SymbolsNerdFont-Regular.ttf"  # ttf-nerd-fonts-symbols

W, H = 2560, 1440

SAND, BLUE, BLUE_L, NAVY = (236, 196, 140), (40, 100, 200), (96, 160, 255), (20, 40, 92)
WHITE, DIM, FAINT, GREEN = (240, 244, 250), (150, 162, 188), (70, 80, 104), (130, 200, 110)
INK, SPACE = (6, 12, 28), (1, 2, 6)

# Menu geometry, shared by both variants. The selection box is 84 px tall:
# 8 px top/bottom slices around a 68 px item, one row every 96 px.
UNIT = 4                         # one "pixel" of the pixel-art chrome
ITEM_H, ITEM_GAP, BOX_PAD = 68, 28, 8
SEL_LEFT = 70                    # left slice width: border + room for the arrow
ICON, ICON_GAP = 60, 28
MENU_ROWS = 4
MENU_H = MENU_ROWS * (ITEM_H + ITEM_GAP) - ITEM_GAP + 2 * BOX_PAD + 4
BAR_H, BAR_PAD = 28, 8

ENTRIES = [  # grub-mkconfig on Z790E after grub-tweaks.sh (classes drive the icons)
    ("Arch Linux", ["arch", "gnu-linux", "gnu", "os"]),
    ("Arch Linux (fallback)", ["arch", "gnu-linux", "gnu", "os"]),
    ("Windows 11", ["windows", "os"]),
    ("UEFI Firmware Settings", ["efi"]),  # class added by grub-tweaks.sh
]
BOOTNEXT = [  # what /etc/grub.d/31_efi_bootnext adds unless GRUB_DISABLE_BOOTNEXT=true
    ("Windows Boot Manager (EFI BootNext)", ["windows", "os"]),
    ("UEFI OS (EFI BootNext)", ["uefi", "os"]),
    ("UEFI OS (EFI BootNext)", ["uefi", "os"]),
    ("UEFI:  USB, Partition 1 (EFI BootNext)", ["uefi_", "os"]),
    ("UEFI:  USB, Partition 2 (EFI BootNext)", ["uefi_", "os"]),
    ("UEFI:CD/DVD Drive (EFI BootNext)", ["uefi_cd_dvd", "os"]),
    ("UEFI:Removable Device (EFI BootNext)", ["uefi_removable", "os"]),
    ("UEFI:Network Device (EFI BootNext)", ["uefi_network", "os"]),
]


# ── Helpers ──────────────────────────────────────────────────────────────

def rgba(c, a=255):
    return (c[0], c[1], c[2], a)


def hexc(c):
    return "#%02X%02X%02X" % c


def X(x):
    """Absolute x on the 2560 canvas -> GRUB proportional spec."""
    return "50%%%+d" % (x - W // 2)


def Y(y):
    return "50%%%+d" % (y - H // 2)


class Face:
    """A typeface, used for text baked into background.png and for the PF2
    fonts GRUB draws with (those are always 1-bit, whatever the face).

    tracking is extra letter spacing in px for baked text.
    """

    def __init__(self, path, pixel=False, tracking=0):
        self.path, self.pixel, self.tracking = path, pixel, tracking

    def font(self, size):
        return ImageFont.truetype(self.path, size)

    def pf2(self, theme_dir, size):
        return mkfont(theme_dir, self.path, size, ASCII)

    def width(self, s, size):
        f = self.font(size)
        return sum(f.getlength(c) for c in s) + self.tracking * (len(s) - 1) if self.tracking else f.getlength(s)

    def text(self, img, xy, s, size, color, anchor="ls"):
        """Draw s, return its advance."""
        d, f = ImageDraw.Draw(img), self.font(size)
        if self.pixel:
            d.fontmode = "1"  # aliased like GRUB's own 1-bit glyphs
        if not self.tracking:
            d.text(xy, s, font=f, fill=color, anchor=anchor)
            return d.textlength(s, font=f)
        w = self.width(s, size)
        x = xy[0] - {"l": 0, "m": w / 2, "r": w}[anchor[0]]
        for c in s:
            d.text((x, xy[1]), c, font=f, fill=color, anchor="l" + anchor[1])
            x += f.getlength(c) + self.tracking
        return w


PIXEL = Face(PIXELON, pixel=True)


def ptext(img, xy, s, size, color, anchor="ls"):
    """Baked pixel text."""
    return PIXEL.text(img, xy, s, size, color, anchor)


def pixel_box(w, h, fill, border, unit=UNIT):
    """Rectangle with a one-unit border and notched (stepped) corners."""
    gw, gh = w // unit, h // unit
    im = Image.new("RGBA", (gw, gh), fill if len(fill) == 4 else rgba(fill))
    px = im.load()
    for x in range(gw):
        px[x, 0] = px[x, gh - 1] = rgba(border)
    for y in range(gh):
        px[0, y] = px[gw - 1, y] = rgba(border)
    for cx, cy in ((0, 0), (gw - 1, 0), (0, gh - 1), (gw - 1, gh - 1)):
        px[cx, cy] = (0, 0, 0, 0)
    for cx, cy in ((1, 1), (gw - 2, 1), (1, gh - 2), (gw - 2, gh - 2)):
        px[cx, cy] = rgba(border)
    return im.resize((gw * unit, gh * unit), Image.NEAREST)


def pixel_icon(rows, scale, color):
    w = max(len(r) for r in rows)
    im = Image.new("RGBA", (w, len(rows)), (0, 0, 0, 0))
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch == "#":
                im.putpixel((x, y), rgba(color))
    return im.resize((w * scale, len(rows) * scale), Image.NEAREST)


def circle_rows(n, r_out, r_in=0.0, extra=None):
    c = (n - 1) / 2
    return ["".join("#" if (r_in <= math.hypot(x - c, y - c) <= r_out
                            or (extra and extra(x, y, math.hypot(x - c, y - c)))) else "."
                    for x in range(n)) for y in range(n)]


PX_ICONS = {
    "arch": [".....##.....", ".....##.....", "....####....", "....####....",
             "...######...", "....#####...", "..########..", "..###..###..",
             ".###....###.", ".###....###.", "####....####", "##........##"],
    "windows": ["............", ".#####.#####", ".#####.#####", ".#####.#####",
                ".#####.#####", ".#####.#####", "............", ".#####.#####",
                ".#####.#####", ".#####.#####", ".#####.#####", ".#####.#####"],
    "uefi": ["..#.#..#.#..", "............", "#.########.#", "..#......#..",
             "#.#.####.#.#", "..#.#..#.#..", "#.#.#..#.#.#", "..#.####.#..",
             "#.#......#.#", "..########..", "............", "..#.#..#.#.."],
    "uefi_": ["....####....", "....#..#....", "....#..#....", "...######...",
              "...######...", "...######...", "...######...", "...######...",
              "....####....", ".....##.....", ".....##.....", ".....##....."],
    "uefi_cd_dvd": circle_rows(12, 5.8, 1.6),
    "uefi_removable": ["....######..", "...#.#.#.#..", "..########..", "..########..",
                       "..########..", "..########..", "..########..", "..########..",
                       "..########..", "..########..", "..########..", "............"],
    "uefi_network": circle_rows(12, 5.8, 4.7, lambda x, y, d: d < 5 and (y in (5, 6) or x in (5, 6))),
    "os": ["############", "#..........#", "#..........#", "#..........#",
           "#..........#", "#..........#", "#..........#", "############",
           ".....##.....", "....####....", "............", "............"],
}
PX_ICONS["efi"] = PX_ICONS["uefi"]  # "UEFI Firmware Settings", class added by grub-tweaks.sh
PX_ARROW = ["#...", "##..", "###.", "####", "###.", "##..", "#..."]
SAT = ["##..#..##", "##.###.##", "#########", "##.###.##", "##..#..##"]

NF_ICONS = {  # the same classes as Symbols Nerd Font glyphs, for the smooth icon set
    "arch": 0xF303,            # linux-archlinux
    "windows": 0xE62A,         # custom-windows (flat Windows 11 panes)
    "uefi": 0xF2DB,            # fa-microchip
    "uefi_": 0xF129E,          # md-usb_flash_drive
    "uefi_cd_dvd": 0xF05EE,    # md-disc
    "uefi_removable": 0xF0479,  # md-sd
    "uefi_network": 0xF059F,   # md-web
    "os": 0xF0379,             # md-monitor
}
NF_ICONS["efi"] = NF_ICONS["uefi"]


def smooth(mask, size):
    """Supersampled L mask -> SAND icon of the given size, straight alpha."""
    im = Image.new("RGBA", size, rgba(SAND))
    im.putalpha(mask.resize(size, Image.LANCZOS))
    return im


def glyph_icon(cp, size=60, fit=52):
    """A Nerd Font glyph fitted into a size x size icon."""
    big = 8 * size
    mask = Image.new("L", (2 * big, 2 * big))
    ImageDraw.Draw(mask).text((big, big), chr(cp), font=ImageFont.truetype(NERD, big), fill=255, anchor="mm")
    mask = mask.crop(mask.getbbox())
    if cp == NF_ICONS["arch"]:  # cut the ™ that sits right of the logo, past a gap
        cols = np.flatnonzero(np.asarray(mask).max(axis=0))
        gaps = np.flatnonzero(np.diff(cols) > 1)
        if gaps.size:
            mask = mask.crop((0, 0, cols[gaps[0]] + 1, mask.height))
            mask = mask.crop(mask.getbbox())
    s = fit / max(mask.size)
    w, h = round(mask.width * s), round(mask.height * s)
    icon = Image.new("L", (size, size))
    icon.paste(mask.resize((w, h), Image.LANCZOS), ((size - w) // 2, (size - h) // 2))
    return smooth(icon, (size, size))


def smooth_arrow(w=20, h=34, ss=8):
    """The selection arrow, same size as PX_ARROW at scale 5, anti-aliased."""
    mask = Image.new("L", (w * ss, h * ss))
    ImageDraw.Draw(mask).polygon([(0, 0), (w * ss, h * ss / 2), (0, h * ss)], fill=255)
    return smooth(mask, (w, h))


# ── PF2 fonts ────────────────────────────────────────────────────────────

class Pf2:
    """Just enough of GRUB's PF2 format to read metrics and draw glyphs."""

    def __init__(self, path):
        self.path = Path(path)
        data = self.path.read_bytes()
        self.data, self.index, pos = data, {}, 0
        while pos < len(data):
            sec, length = data[pos:pos + 4].decode(), struct.unpack(">I", data[pos + 4:pos + 8])[0]
            pos += 8
            if sec == "DATA":
                break
            body = data[pos:pos + length]
            pos += length
            if sec == "NAME":
                self.name = body.rstrip(b"\0").decode()
            elif sec == "ASCE":
                self.ascent = struct.unpack(">H", body)[0]
            elif sec == "DESC":
                self.descent = struct.unpack(">H", body)[0]
            elif sec == "CHIX":
                for i in range(0, len(body), 9):
                    code, _, off = struct.unpack(">IBI", body[i:i + 9])
                    self.index[code] = off

    def glyph(self, ch):
        off = self.index.get(ord(ch), self.index.get(ord("?")))
        w, h, xo, yo, dw = struct.unpack(">HHhhh", self.data[off:off + 10])
        bits = np.unpackbits(np.frombuffer(self.data[off + 10:off + 10 + (w * h + 7) // 8], np.uint8))
        mask = Image.fromarray((bits[:w * h].reshape(h, w) * 255).astype(np.uint8), "L") if w and h else None
        return mask, xo, yo, dw

    def width(self, s):
        return sum(self.glyph(ch)[3] for ch in s)

    def draw(self, img, x, baseline, s, color):
        for ch in s:
            mask, xo, yo, dw = self.glyph(ch)
            if mask is not None:
                img.paste(Image.new("RGBA", mask.size, rgba(color)),
                          (x + xo, baseline - yo - mask.height), mask)
            x += dw


def mkfont(theme_dir, src, size, ranges):
    """PF2 from a font file.

    GRUB finds fonts by the PF2 name, "<family> <Regular|Bold|Italic> <size>",
    so e.g. the Medium and SemiBold files of a family would share one. Any
    other style goes into the family name to keep them apart.
    """
    out = theme_dir / ("%s-%d.pf2" % (Path(src).stem.split(".")[0].lower(), size))
    cmd = ["grub-mkfont", "-s", str(size), "-r", ranges, "-o", str(out)]
    f = ImageFont.truetype(src, size)
    if f.font.style not in ("Regular", "Bold", "Italic", "Bold Italic"):
        cmd += ["-n", f"{f.font.family} {f.font.style}"]
    r = subprocess.run(cmd + [src], capture_output=True, text=True)
    if r.returncode:  # otherwise stderr is just "unsupported font feature" warnings
        raise SystemExit(r.stderr)
    return Pf2(out)


ASCII = "0x20-0x7E"
CONSOLE = "0x20-0x7E,0xA0-0xFF,0x2190-0x21FF,0x2500-0x259F"


# ── Backgrounds ──────────────────────────────────────────────────────────

def starfield(seed, n, clear=(), k=1):
    """Stars on SPACE, none inside the clear boxes. Positions and boxes are in
    the 2560x1440 layout; k draws the same stars k times larger."""
    rnd = random.Random(seed)
    base = Image.new("RGB", (round(W * k), round(H * k)), SPACE)
    layer = Image.new("RGB", base.size, (0, 0, 0))
    d = ImageDraw.Draw(layer)
    for _ in range(n):
        x, y = rnd.uniform(0, W), rnd.uniform(0, H)
        b = rnd.random() ** 3
        if any(x0 <= x <= x1 and y0 <= y <= y1 for x0, y0, x1, y1 in clear):
            continue
        x, y, r, c = x * k, y * k, (0.8 + 2.4 * b) * k, int(90 + 165 * b)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(c, c, min(255, c + 12)))
        if b > 0.75:
            for dx, dy in ((7 * k, 0), (0, 7 * k)):
                d.line((x - dx, y - dy, x + dx, y + dy), fill=(c // 2,) * 3, width=round(k))
    glow = layer.filter(ImageFilter.GaussianBlur(3 * k))
    return ImageChops.add(base, ImageChops.add(layer, glow)).convert("RGBA")


def earth_disc(src, cx, cy, radius, size):
    """Round crop of the planet with a feathered edge, resized to size."""
    crop = src.crop((cx - radius, cy - radius, cx + radius, cy + radius)).resize((size, size), Image.LANCZOS)
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32)
    r = np.hypot(xx - size / 2, yy - size / 2) / (size / 2)
    mask = Image.fromarray((np.clip((1 - r) / 0.13, 0, 1) * 255).astype(np.uint8), "L")
    return crop.convert("RGBA"), mask


def dashes(img, x0, x1, y, color, step=16, size=8):
    d = ImageDraw.Draw(img)
    for x in range(x0, x1, step):
        d.rectangle((x, y, x + size - 1, y + size - 1), fill=color)


def hints(img, x, y, size, gap, center=False, key=PIXEL, action=PIXEL):
    items = (("UP/DOWN", "SELECT"), ("ENTER", "LAUNCH"), ("E", "EDIT"), ("C", "CONSOLE"))
    if center:
        d = ImageDraw.Draw(img)
        x -= (sum(d.textlength(k + " " + a, font=key.font(size)) for k, a in items) + gap * (len(items) - 1)) / 2
    for k, a in items:
        x += key.text(img, (x, y), k + " ", size, SAND)
        x += action.text(img, (x, y), a, size, FAINT) + gap


# ── Shared GRUB assets ───────────────────────────────────────────────────

SLICES = ("nw", "n", "ne", "w", "c", "e", "sw", "s", "se")


def save_box(img, theme_dir, prefix, left, top, right, bottom, only=SLICES):
    """Cut a full-size box image into GRUB's 9 slices.

    W/E keep the full content height (GRUB scales them to the item height,
    which they already have), N/S/C are one pixel wide and get stretched.
    """
    w, h = img.size
    boxes = {
        "nw": (0, 0, left, top), "n": (left, 0, left + 1, top), "ne": (w - right, 0, w, top),
        "w": (0, top, left, h - bottom), "c": (left, top, left + 1, top + 1), "e": (w - right, top, w, h - bottom),
        "sw": (0, h - bottom, left, h), "s": (left, h - bottom, left + 1, h), "se": (w - right, h - bottom, w, h),
    }
    for name in only:
        b = boxes[name]
        if b[2] > b[0] and b[3] > b[1]:
            img.crop(b).save(theme_dir / f"{prefix}{name}.png")


def common_assets(theme_dir, smooth_icons=False):
    # selected item: notched box, arrow inside the left slice
    sel = pixel_box(400, ITEM_H + 2 * BOX_PAD, NAVY, BLUE_L)
    arrow = smooth_arrow() if smooth_icons else pixel_icon(PX_ARROW, 5, SAND)
    sel.alpha_composite(arrow, (22, (sel.height - arrow.height) // 2))
    save_box(sel, theme_dir, "select_", SEL_LEFT, BOX_PAD, BOX_PAD, BOX_PAD)
    # unselected item: same slice sizes, fully transparent, so text never jumps
    save_box(Image.new("RGBA", sel.size, (0, 0, 0, 0)), theme_dir, "item_", SEL_LEFT, BOX_PAD, BOX_PAD, BOX_PAD)
    # progress bar: notched frame, solid highlight
    save_box(pixel_box(200, BAR_H, INK, (190, 200, 222)), theme_dir, "bar_", BAR_PAD, BAR_PAD, BAR_PAD, BAR_PAD)
    Image.new("RGBA", (1, 1), rgba(BLUE)).save(theme_dir / "hl_c.png")
    # scrollbar (only drawn when there are more entries than rows)
    track = Image.new("RGBA", (12, 1), (0, 0, 0, 0))
    track.paste(rgba(FAINT), (4, 0, 8, 1))
    track.save(theme_dir / "scroll_frame_c.png")
    Image.new("RGBA", (12, 1), rgba(SAND)).save(theme_dir / "scroll_thumb_c.png")
    icons = theme_dir / "icons"
    icons.mkdir()
    if smooth_icons:
        for cls, cp in NF_ICONS.items():
            glyph_icon(cp).save(icons / f"{cls}.png")
    else:
        for cls, rows in PX_ICONS.items():
            pixel_icon(rows, 5, SAND).save(icons / f"{cls}.png")


def boot_menu(x, y, w, font):
    return f"""
+ boot_menu {{
  left = {X(x)}
  top = {Y(y)}
  width = {w}
  height = {MENU_H}
  item_font = "{font.name}"
  selected_item_font = "{font.name}"
  item_color = "{hexc(DIM)}"
  selected_item_color = "{hexc(WHITE)}"
  icon_width = {ICON}
  icon_height = {ICON}
  item_icon_space = {ICON_GAP}
  item_height = {ITEM_H}
  item_padding = 0
  item_spacing = {ITEM_GAP}
  item_pixmap_style = "item_*.png"
  selected_item_pixmap_style = "select_*.png"
  scrollbar = true
  scrollbar_width = 12
  scrollbar_left_pad = 16
  scrollbar_right_pad = 0
  scrollbar_frame = "scroll_frame_*.png"
  scrollbar_thumb = "scroll_thumb_*.png"
}}
"""


def label(x, baseline, w, font, color, text, align="left"):
    return f"""
+ label {{
  id = "__timeout__"
  left = {X(x)}
  top = {Y(baseline - font.ascent)}
  width = {w}
  height = {font.ascent + font.descent}
  text = "{text}"
  font = "{font.name}"
  color = "{hexc(color)}"
  align = "{align}"
}}
"""


def progress(x, y, w):
    return f"""
+ progress_bar {{
  id = "__timeout__"
  left = {X(x)}
  top = {Y(y)}
  width = {w}
  height = {BAR_H}
  bar_style = "bar_*.png"
  highlight_style = "hl_*.png"
  highlight_overlay = false
}}
"""


def header(title, console):
    return f"""# Pixel Orbit — {title}
# Generated by Dotfiles/.local/share/grub-themes/pixel-orbit/build.py; edit that, not this.
# Laid out for 2560x1440; larger framebuffers show the canvas centred on black.
# GRUB paints components in reverse order, so the background image comes last.
# The terminal (console, editor) is full-screen and frameless: booting an entry
# clears only the terminal area and leaves the rest of the menu up, so a smaller
# terminal shows as a box until the kernel's graphics driver takes over.

title-text: ""
desktop-color: "{hexc(SPACE)}"
terminal-font: "{console.name}"
terminal-left: "0"
terminal-top: "0"
terminal-width: "100%"
terminal-height: "100%"
terminal-border: "0"
"""


BACKGROUND = """
+ image {
  left = 50%-1280
  top = 50%-720
  width = 2560
  height = 1440
  file = "background.png"
}
"""


# ── Variant B · Telemetry ────────────────────────────────────────────────

# Text roles -> (face, size). item, clock and status are drawn by GRUB (PF2),
# the rest is baked into the background. Sizes are matched by cap height.
PIXEL_TYPE = {
    "title": (PIXEL, 103), "kicker": (PIXEL, 31), "key": (PIXEL, 21), "value": (PIXEL, 31),
    "hint_key": (PIXEL, 31), "hint": (PIXEL, 31),
    "item": (PIXEL, 41), "clock": (PIXEL, 103), "status": (PIXEL, 31),
}
SANS_TYPE = {  # Monaspace Krypton; thin weights break up as 1-bit glyphs, so SemiBold+
    "title": (Face(KRYPTON % "SemiWideBold"), 96), "kicker": (Face(KRYPTON % "SemiBold", tracking=2), 27),
    "key": (Face(KRYPTON % "SemiBold", tracking=1), 18), "value": (Face(KRYPTON % "SemiBold"), 29),
    "hint_key": (Face(KRYPTON % "Bold"), 25), "hint": (Face(KRYPTON % "Medium"), 25),
    "item": (Face(KRYPTON % "SemiBold"), 40), "clock": (Face(KRYPTON % "SemiWideBold"), 96),
    "status": (Face(KRYPTON % "Bold"), 27),
}


# The orbit scene, shared with the boot splash: the planet, a tilted orbit of
# dots (the far half behind the planet) and the satellite on it.
EARTH_C, ORBIT_C, ORBIT_R = (1900, 640), (1900, 700), (600, 150)


# k scales the scene for larger displays; E must then be the wallpaper at k x 2560x1440.

def orbit_earth(E, k=1):
    """The planet disc, its feathered mask and its top-left corner."""
    disc, mask = earth_disc(E, 1275 * k, 732 * k, 545 * k, int(1090 * 0.9 * k))
    return disc, mask, (round(EARTH_C[0] * k) - disc.width // 2, round(EARTH_C[1] * k) - disc.height // 2)


def orbit_dots(img, back, k=1):
    d = ImageDraw.Draw(img)
    for i in range(0, 360, 3):
        a = math.radians(i)
        px, py = (ORBIT_C[0] + ORBIT_R[0] * math.cos(a)) * k, (ORBIT_C[1] + ORBIT_R[1] * math.sin(a)) * k
        if (py < ORBIT_C[1] * k) == back:
            d.rectangle((px - 3 * k, py - 3 * k, px + 2 * k, py + 2 * k), fill=(70, 110, 170) if back else BLUE_L)


def satellite_xy(a, sat, k=1):
    return (int((ORBIT_C[0] + ORBIT_R[0] * math.cos(a)) * k - sat.width / 2),
            int((ORBIT_C[1] + ORBIT_R[1] * math.sin(a)) * k - sat.height / 2))


def telemetry(theme_dir, E, sans=False):
    """sans: smooth text and icons on the same pixel-art background."""
    T = SANS_TYPE if sans else PIXEL_TYPE
    item, clock, status = (face.pf2(theme_dir, size) for face, size in (T["item"], T["clock"], T["status"]))
    console = mkfont(theme_dir, TERMINUS, 24, CONSOLE)  # always built: install.sh makes it GRUB_FONT
    if sans:  # 17x35 px cells; grub-tweaks.sh places the boot log on this grid
        console = mkfont(theme_dir, KRYPTON % "SemiBold", 28, CONSOLE)

    def text(role, xy, s, color):
        face, size = T[role]
        return face.text(bg, xy, s, size, color)

    x, kicker = 200, "MISSION CONTROL  ·  BOOT SELECT"
    if sans:
        # Stars run behind the text, kept only off the padded text lines (and
        # the menu rows as grub-mkconfig names them), not whole panels.
        pad = 32  # a dim star a letter-width from a word reads as punctuation

        def line(role, x0, baseline, s):
            face, size = T[role]
            asc, desc = face.font(size).getmetrics()
            return (x0 - pad, baseline - asc - pad, x0 + face.width(s, size) + pad, baseline + desc + pad)

        clear = [line("title", x, 300, "Z790E"), line("kicker", x + 4, 360, kicker),
                 (x - pad, 1285, x + 1160, 1350),  # key hints
                 line("clock", 1620, 1190, "T-88"), line("status", 1990, 1150, "AUTO-LAUNCH"),
                 line("status", 1990, 1190, "ARMED")]
        item_face, item_size = T["item"]
        for i, (title, _) in enumerate(ENTRIES):
            top = 440 + i * (ITEM_H + ITEM_GAP)
            right = x + SEL_LEFT + ICON + ICON_GAP + item_face.width(title, item_size) + pad
            clear.append((x + SEL_LEFT - pad, top, right, top + ITEM_H + 2 * BOX_PAD))
    else:
        clear = [(150, 160, 1420, 1200), (150, 1285, 1420, 1350), (1560, 1080, 2460, 1360)]
    bg = starfield(21, 480, clear=clear)
    orbit_dots(bg, back=True)
    disc, mask, xy = orbit_earth(E)
    bg.paste(disc, xy, mask)
    orbit_dots(bg, back=False)
    sat = pixel_icon(SAT, 5, SAND)
    bg.alpha_composite(sat, satellite_xy(math.radians(140), sat))

    text("title", (x, 300), "Z790E", WHITE)
    text("kicker", (x + 4, 360), kicker, SAND)
    dashes(bg, x, x + 1160, 392, FAINT)
    cells = (("FIRMWARE", "UEFI"), ("ARCH", "X86_64"), ("LOADER", "GRUB"), ("MODE", "2560X1440"))
    cw = (1160 - 3 * 20) // 4
    for i, (k, v) in enumerate(cells):
        cx = x + i * (cw + 20)
        bg.alpha_composite(pixel_box(cw, 120, INK, FAINT), (cx, 900))
        text("key", (cx + 24, 948), k, DIM)
        text("value", (cx + 24, 996), v, SAND)
    hints(bg, x, 1330, T["hint"][1], 56, key=T["hint_key"][0], action=T["hint"][0])
    bg.convert("RGB").save(theme_dir / "background.png")

    common_assets(theme_dir, smooth_icons=sans)
    theme = header("Telemetry Sans" if sans else "Telemetry", console)
    theme += boot_menu(x, 440, 1160, item)
    theme += label(1620, 1190, 380, clock, WHITE, "T-%02d")
    theme += label(1990, 1150, 400, status, SAND, "AUTO-LAUNCH")
    theme += label(1990, 1190, 400, status, GREEN, "ARMED")
    theme += progress(1620, 1226, 820)
    theme += BACKGROUND
    (theme_dir / "theme.txt").write_text(theme)


# ── Variant D · Horizon ──────────────────────────────────────────────────

def horizon(theme_dir, E0):
    f31, f41 = (mkfont(theme_dir, PIXELON, s, ASCII) for s in (31, 41))
    console = mkfont(theme_dir, TERMINUS, 24, CONSOLE)

    bg = starfield(9, 560, clear=[(660, 150, 1900, 380), (660, 430, 1900, 790), (900, 800, 1660, 960)])
    size = int(2 * 760 * 1.3)  # planet from the 3840 original, 1.3x
    disc, mask = earth_disc(E0, 1912, 1098, 760, size)
    bg.paste(disc, (W // 2 - size // 2 + 60, 1010 - int(size * 0.17)), mask)
    ptext(bg, (W // 2, 230), "Z790E", 82, WHITE, anchor="ms")
    ptext(bg, (W // 2, 290), "SELECT BOOT TARGET", 31, SAND, anchor="ms")
    hints(bg, W // 2, 940, 21, 40, center=True)
    bg.convert("RGB").save(theme_dir / "background.png")

    common_assets(theme_dir)
    theme = header("Horizon", console)
    theme += boot_menu(680, 350, 1200, f41)
    theme += label(980, 816, 600, f31, SAND, "LAUNCH IN %02d", align="center")
    theme += progress(980, 838, 600)
    theme += BACKGROUND
    (theme_dir / "theme.txt").write_text(theme)


# ── Boot splash (Plymouth) ───────────────────────────────────────────────
#
# What follows the menu. Picking an entry puts the splash's opening frame up at
# once: GRUB draws launch.png (installed as /boot/grub/pixel-orbit-launch.png,
# see grub-tweaks.sh) while it loads the kernel. Plymouth, first thing in the
# initramfs, takes over that same frame and sets it moving: the satellite flies,
# stars twinkle, then the launch log types itself in and a progress bar fills
# until SDDM. Plymouth's script plugin only places, crops and fades images, so
# all text is rendered here.
#
# The images come in one set per display size (SPLASH_SETS). Booting runs on
# the firmware framebuffer at GRUB_GFXMODE, 2560x1440; shutdown and reboot run
# on the NVIDIA driver at the monitors' native 3840x2160. The script picks the
# largest set that fits the display.

GRUB_CFG = Path("/boot/grub/grub.cfg")
SPLASH_SETS = {"1440": 1, "2160": 1.5}    # set name (display height) -> scale of the 2560x1440 layout
FPS, ORBIT_S = 50, 12                     # Plymouth's frame rate, seconds per orbit
LOG_X, LOG_Y, LOG_LINE = 204, 420, 35     # the log sits where the menu list was
TYPE_AT, TYPE_PX, TYPE_GAP = 40, 34, 6    # first line at frame 40, 2 chars a frame, 6 frames between lines
LOG_FACE, LOG_SIZE, LOG_TEXT = Face(KRYPTON % "SemiBold"), 28, (204, 212, 228)


def grub_entries(cfg):
    """{title: (kernel, root, initrd)} for the Linux entries in grub.cfg."""
    out = {}
    for entry in cfg.read_text().split("\nmenuentry '")[1:]:
        linux = re.search(r"^\s*linux\s+(\S+)\s+root=(\S+)", entry, re.M)
        initrd = re.search(r"^\s*initrd\s+(.+)$", entry, re.M)
        if linux and initrd:
            out[entry.split("'", 1)[0]] = (linux[1], linux[2], initrd[1].strip())
    return out


def launch_log(title, kernel, root, initrd):
    """[(row, [(text, color), ...])] of the boot log."""
    return [(0, [("LAUNCH SEQUENCE  ·  " + title, WHITE)]),
            (2, [("kernel      ", DIM), (kernel, LOG_TEXT)]),
            (3, [("root        ", DIM), (root, LOG_TEXT)]),
            (4, [("initramfs   ", DIM), (initrd, LOG_TEXT)]),
            (6, [("Starting Linux ...", DIM)])]


def log_strip(parts, k=1):
    """One log line as an image starting at LOG_X, so every variant of a line
    (default or fallback entry) sits at the same place."""
    size = round(LOG_SIZE * k)
    asc, desc = LOG_FACE.font(size).getmetrics()
    w = sum(LOG_FACE.width(t, size) for t, _ in parts)
    img, x = Image.new("RGBA", (math.ceil(w) + 2, asc + desc)), 0
    for t, color in parts:
        x += LOG_FACE.text(img, (x, asc), t, size, color)
    return img


def glint_image(size=15, ss=8):
    """A four-point sparkle for the twinkling stars."""
    s, c, k = size * ss, size * ss / 2, 0.6 * ss
    mask = Image.new("L", (s, s))
    d = ImageDraw.Draw(mask)
    d.polygon([(c, 0), (c + k, c), (c, s), (c - k, c)], fill=170)
    d.polygon([(0, c), (c, c - k), (s, c), (c, c + k)], fill=170)
    d.ellipse((c - 2 * k, c - 2 * k, c + 2 * k, c + 2 * k), fill=255)
    im = Image.new("RGBA", (size, size), (235, 240, 255, 255))
    im.putalpha(mask.resize((size, size), Image.LANCZOS))
    return im


def splash_set(set_dir, src, k, logs, fallback_log, clear, glints):
    """Writes one set of splash images, k times the 2560x1440 layout, into
    set_dir; returns where the script puts them and a frame 3 s in."""
    s = lambda v: round(v * k)
    lines = {mode: [(s(LOG_Y + row * LOG_LINE), log_strip(parts, k)) for row, parts in log]
             for mode, log in logs.items()}
    fallback = [(s(LOG_Y + row * LOG_LINE), log_strip(parts, k)) for row, parts in fallback_log]

    # progress bar: the countdown bar's style, a line under the log, as wide as its widest line
    unit, pad, bh = s(UNIT), s(BAR_PAD), s(BAR_H)
    bx, by = s(LOG_X), s(LOG_Y + (logs["boot"][-1][0] + 1) * LOG_LINE + 10)
    bw = max(im.width for _, im in lines["boot"]) // unit * unit
    bar = pixel_box(bw, bh, INK, (190, 200, 222), unit)
    fill = Image.new("RGBA", (1, bh - 2 * pad), rgba(BLUE))

    sky = starfield(21, 480, clear=clear, k=k)  # the menu's stars, minus those near the log
    orbit_dots(sky, back=True, k=k)
    disc, mask, earth_xy = orbit_earth(src, k)
    disc.putalpha(mask)
    front = Image.new("RGBA", sky.size)
    orbit_dots(front, back=False, k=k)
    front_box = front.getbbox()
    front = front.crop(front_box)
    sat, glint = pixel_icon(SAT, s(5), SAND), glint_image(s(15))
    a0, step = math.radians(140), 2 * math.pi / (ORBIT_S * FPS)  # starts where the menu's satellite sits

    def scene(a):
        """Sky, planet, orbit and the satellite at angle a."""
        frame = sky.copy()
        near = math.sin(a) >= 0
        if not near:
            frame.alpha_composite(sat, satellite_xy(a, sat, k))
        frame.alpha_composite(disc, earth_xy)
        frame.alpha_composite(front, front_box[:2])
        if near:
            frame.alpha_composite(sat, satellite_xy(a, sat, k))
        return frame

    files = {"sky.png": sky.convert("RGB"), "earth.png": disc, "orbit.png": front,
             "satellite.png": sat, "glint.png": glint, "bar.png": bar, "fill.png": fill}
    for mode, strips in lines.items():
        files.update({f"{mode}-{i}.png": im for i, (_, im) in enumerate(strips)})
    files.update({f"fallback/boot-{i}.png": im for i, (_, im) in enumerate(fallback)})
    for name, im in files.items():
        im.save(set_dir / name)

    preview = scene(a0 + 3 * FPS * step)
    for x, y, *_ in glints:
        preview.alpha_composite(glint, (s(x) - glint.width // 2, s(y) - glint.height // 2))
    for y, im in lines["boot"]:
        preview.alpha_composite(im, (bx, y))
    preview.alpha_composite(bar, (bx, by))
    preview.alpha_composite(fill.resize(((bw - 2 * pad) * 2 // 5, fill.height)), (bx + pad, by + pad))

    return {"w": sky.width, "h": sky.height, "k": k, "earth_x": earth_xy[0], "earth_y": earth_xy[1],
            "orbit_x": front_box[0], "orbit_y": front_box[1], "cx": s(ORBIT_C[0]), "cy": s(ORBIT_C[1]),
            "rx": s(ORBIT_R[0]), "ry": s(ORBIT_R[1]), "sat_w": sat.width, "sat_h": sat.height,
            "glint_half": glint.width // 2, "log_x": bx, "type_px": s(TYPE_PX),
            "bar_x": bx, "bar_y": by, "fill_x": bx + pad, "fill_y": by + pad,
            "fill_h": fill.height, "inner": bw - 2 * pad,
            "lines": {mode: [y for y, _ in strips] for mode, strips in lines.items()},
            "launch": scene(a0).convert("RGB"), "preview": preview.convert("RGB"), "a0": a0, "step": step}


def splash(theme_dir, E, E0):
    """Writes the Plymouth theme into theme_dir: one image set per display size
    (each with fallback/, the fallback entry's log), launch.png (GRUB's opening
    frame) and the script. Returns a preview frame."""
    entries = grub_entries(GRUB_CFG)
    if not entries:
        raise SystemExit(f"no Linux entries in {GRUB_CFG}")
    default = next(iter(entries.items()))
    fallback = next(((t, e) for t, e in entries.items() if "fallback" in e[2]), None)
    logs = {"boot": launch_log(default[0], *default[1])}
    for mode, title in (("shutdown", "SHUTDOWN SEQUENCE"), ("reboot", "REBOOT SEQUENCE")):
        logs[mode] = [(0, [(title + "  ·  Z790E", WHITE)]),
                      (2, [("Stopping services and unmounting file systems ...", LOG_TEXT)])]
    fallback_log = launch_log(fallback[0], *fallback[1]) if fallback else []

    # stars stay off the text and the bar, nothing else (2560x1440 layout, so every set has the same stars)
    pad, boxes = 16, []
    for row, parts in [*(line for log in logs.values() for line in log), *fallback_log]:
        y, st = LOG_Y + row * LOG_LINE, log_strip(parts)
        boxes.append((LOG_X - pad, y - pad, LOG_X + st.width + pad, y + st.height + pad))
    by = LOG_Y + (logs["boot"][-1][0] + 1) * LOG_LINE + 10
    bw = max(log_strip(parts).width for _, parts in logs["boot"]) // UNIT * UNIT
    boxes.append((LOG_X - pad, by - pad, LOG_X + bw + pad, by + BAR_H + pad))

    rnd, glints = random.Random(5), []
    while len(glints) < 16:
        x, y = rnd.randrange(40, W - 40), rnd.randrange(40, H - 40)
        if math.dist((x, y), EARTH_C) > 520 and not any(
                x0 - 30 <= x <= x1 + 30 and y0 - 30 <= y <= y1 + 30 for x0, y0, x1, y1 in boxes):
            glints.append((x, y, rnd.uniform(0, 2 * math.pi), rnd.uniform(0.04, 0.09)))

    sets = []
    for name, k in SPLASH_SETS.items():
        (theme_dir / name / "fallback").mkdir(parents=True)
        src = E if k == 1 else E0.resize((round(W * k), round(H * k)), Image.LANCZOS)
        sets.append((name, splash_set(theme_dir / name, src, k, logs, fallback_log, boxes, glints)))
    sets[0][1]["launch"].save(theme_dir / "launch.png")  # GRUB_GFXMODE is 2560x1440

    fields = ("w", "h", "k", "earth_x", "earth_y", "orbit_x", "orbit_y", "cx", "cy", "rx", "ry", "sat_w",
              "sat_h", "glint_half", "log_x", "type_px", "bar_x", "bar_y", "fill_x", "fill_y", "fill_h", "inner")
    sets_script = "\n".join(f'set[{i}].dir = "{name}/";\n' + "\n".join(
        f"set[{i}].{f} = {g[f]};" for f in fields) for i, (name, g) in enumerate(sets))
    lines_script = "\nelse ".join(
        f'if (mode == "{mode}")\n  {{\n' + "".join(
            f'    line[{n}].file = "{mode}-{n}.png";'
            + "".join(f" line[{n}].y[{i}] = {g['lines'][mode][n]};" for i, (_, g) in enumerate(sets)) + "\n"
            for n in range(len(log)))
        + "  }" for mode, log in logs.items())
    glints_script = "\n".join(
        f"glint[{i}].x = {x}; glint[{i}].y = {y}; glint[{i}].phase = {p:.3f}; glint[{i}].speed = {sp:.4f};"
        for i, (x, y, p, sp) in enumerate(glints))
    a0, step = sets[0][1]["a0"], sets[0][1]["step"]

    (theme_dir / "pixel-orbit.plymouth").write_text(f"""[Plymouth Theme]
Name=Pixel Orbit
Description=The satellite circling the pixel Earth, a typed launch log and a boot progress bar
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/pixel-orbit
ScriptFile=/usr/share/plymouth/themes/pixel-orbit/pixel-orbit.script
""")
    (theme_dir / "pixel-orbit.script").write_text(f"""# Pixel Orbit boot splash
# Generated by Dotfiles/.local/share/grub-themes/pixel-orbit/build.py; edit that, not this.
# Opens on the frame GRUB already shows (launch.png), sets the satellite moving,
# then types the launch log in line by line and brings up the progress bar.
# One image set per display size (set[]); layout() uses the largest that fits
# and centres it on every display.
#
# z: sky 0, glints 5, satellite 10 (far side) / 40 (near side), earth 20,
# near orbit 30, log and bar 50.

Window.SetBackgroundTopColor(0, 0, 0);
Window.SetBackgroundBottomColor(0, 0, 0);
mode = Plymouth.GetMode();

{sets_script}

sky.sprite = Sprite();
earth.sprite = Sprite();
orbit.sprite = Sprite();
sat.sprite = Sprite();

# Glints: positions in the 2560x1440 layout, scaled by the set's k.
{glints_script}
for (i = 0; glint[i]; i++)
  {{
    glint[i].sprite = Sprite();
    glint[i].sprite.SetOpacity(0);
  }}

# The log: one image per line, revealed left to right (type_px a frame), each
# line starting {TYPE_GAP} frames after the one before it has finished.
{lines_script}
for (i = 0; line[i]; i++)
  {{
    line[i].sprite = Sprite();
    line[i].shown = 0;
  }}

fill_w = 0;
if (mode == "boot")
  {{
    bar.sprite = Sprite();
    bar.sprite.SetOpacity(0);
    fill.sprite = Sprite();
  }}

fun put (sprite, x, y, z)
  {{
    sprite.SetPosition(global.ox + x, global.oy + y, z);
  }}

si = -1;
fun layout ()
  {{
    n = 0;
    for (i = 1; set[i]; i++)
      if (set[i].w <= Window.GetWidth() && set[i].h <= Window.GetHeight())
        n = i;
    if (n != global.si)
      {{
        global.si = n;
        d = set[n].dir;
        sky.sprite.SetImage(Image(d + "sky.png"));
        earth.sprite.SetImage(Image(d + "earth.png"));
        orbit.sprite.SetImage(Image(d + "orbit.png"));
        sat.sprite.SetImage(Image(d + "satellite.png"));
        g = Image(d + "glint.png");
        for (i = 0; glint[i]; i++)
          glint[i].sprite.SetImage(g);
        at = {TYPE_AT};
        for (i = 0; line[i]; i++)
          {{
            line[i].image = Image(d + line[i].file);
            line[i].shown = 0;
            line[i].at = at;
            at = at + Math.Int(line[i].image.GetWidth() / set[n].type_px) + {TYPE_GAP};
          }}
        global.bar_at = at;
        if (bar)
          {{
            bar.sprite.SetImage(Image(d + "bar.png"));
            fill.image = Image(d + "fill.png");
            global.fill_w = 0;
          }}
      }}
    s = set[n];
    global.ox = Window.GetX() + Math.Int((Window.GetWidth() - s.w) / 2);
    global.oy = Window.GetY() + Math.Int((Window.GetHeight() - s.h) / 2);
    put(sky.sprite, 0, 0, 0);
    put(earth.sprite, s.earth_x, s.earth_y, 20);
    put(orbit.sprite, s.orbit_x, s.orbit_y, 30);
    for (i = 0; glint[i]; i++)
      put(glint[i].sprite, Math.Int(glint[i].x * s.k) - s.glint_half, Math.Int(glint[i].y * s.k) - s.glint_half, 5);
    for (i = 0; line[i]; i++)
      put(line[i].sprite, s.log_x, line[i].y[n], 50);
    if (bar)
      {{
        put(bar.sprite, s.bar_x, s.bar_y, 50);
        put(fill.sprite, s.fill_x, s.fill_y, 51);
      }}
  }}

layout();
Plymouth.SetDisplayHotplugFunction(layout);

t = 0;
fun refresh ()
  {{
    global.t = global.t + 1;
    s = set[global.si];
    a = {a0:.4f} + global.t * {step:.6f};
    sn = Math.Sin(a);
    if (sn < 0) z = 10; else z = 40;
    put(sat.sprite, Math.Int(s.cx + s.rx * Math.Cos(a) - s.sat_w / 2), Math.Int(s.cy + s.ry * sn - s.sat_h / 2), z);
    twinkle = Math.Clamp(global.t / {FPS}, 0, 1);
    for (i = 0; glint[i]; i++)
      glint[i].sprite.SetOpacity(twinkle * (0.5 + 0.5 * Math.Sin(global.t * glint[i].speed + glint[i].phase)));
    for (i = 0; line[i]; i++)
      {{
        w = Math.Clamp((global.t - line[i].at) * s.type_px, 0, line[i].image.GetWidth());
        if (w > 0 && w != line[i].shown)
          {{
            line[i].shown = w;
            line[i].sprite.SetImage(line[i].image.Crop(0, 0, w, line[i].image.GetHeight()));
          }}
      }}
    if (bar && global.t <= global.bar_at + 15)
      {{
        b = Math.Clamp((global.t - global.bar_at) / 15, 0, 1);
        bar.sprite.SetOpacity(b);
        fill.sprite.SetOpacity(b);
      }}
  }}
Plymouth.SetRefreshFunction(refresh);

fun progress (duration, p)
  {{
    if (bar)
      {{
        s = set[global.si];
        w = Math.Int(s.inner * Math.Clamp(p, 0, 1));
        if (w < 1) w = 1;
        if (w != global.fill_w)
          {{
            global.fill_w = w;
            fill.sprite.SetImage(fill.image.Scale(w, s.fill_h));
          }}
      }}
  }}
Plymouth.SetBootProgressFunction(progress);

fun quit ()
  {{
    if (bar)
      fill.sprite.SetImage(fill.image.Scale(set[global.si].inner, set[global.si].fill_h));
  }}
Plymouth.SetQuitFunction(quit);
""")
    return sets[0][1]["preview"]


# ── Preview ──────────────────────────────────────────────────────────────

def parse_theme(path):
    """Tiny theme.txt reader: globals + list of (type, props)."""
    comps, cur = [], None
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("+"):
            cur = (line[1:].split("{")[0].strip(), {})
            comps.append(cur)
        elif line == "}":
            cur = None
        elif cur is not None and "=" in line:
            k, v = line.split("=", 1)
            cur[1][k.strip()] = v.strip().strip('"')
    return comps


def spec(v, total):
    v = v.replace("50%", str(total // 2))
    return int(eval(v, {"__builtins__": {}}))  # only digits and +/- from our own writer


def load_box(theme_dir, pattern):
    return {n: Image.open(theme_dir / pattern.replace("*", n)).convert("RGBA")
            for n in SLICES if (theme_dir / pattern.replace("*", n)).exists()}


def pad(box, *names, axis):
    return max([box[n].size[axis] for n in names if n in box] or [0])


def draw_box(img, box, x, y, cw, ch):
    """widget-box.c: draw()."""
    hn, ww = pad(box, "nw", "n", "ne", axis=1), pad(box, "nw", "w", "sw", axis=0)

    def blit(n, px, py, w=None, h=None):
        if n not in box:
            return
        im = box[n]
        if (w or im.width) != im.width or (h or im.height) != im.height:
            im = im.resize((max(1, w or im.width), max(1, h or im.height)), Image.BILINEAR)
        if im.width and im.height:
            img.alpha_composite(im, (px, py))

    blit("n", x + ww, y, w=cw)
    blit("s", x + ww, y + hn + ch, w=cw)
    blit("e", x + ww + cw, y + hn, h=ch)
    blit("w", x, y + hn, h=ch)
    blit("nw", x, y)
    blit("ne", x + ww + cw, y)
    blit("se", x + ww + cw, y + hn + ch)
    blit("sw", x, y + hn + ch)
    if cw > 0 and ch > 0:
        blit("c", x + ww, y + hn, w=cw, h=ch)


def preview(theme_dir, entries, remaining=42, total=60, selected=0):
    comps = parse_theme(theme_dir / "theme.txt")
    fonts = {f.name: f for f in (Pf2(p) for p in theme_dir.glob("*.pf2"))}
    img = Image.new("RGBA", (W, H), rgba(SPACE))
    for kind, p in reversed(comps):
        x, y = spec(p["left"], W), spec(p["top"], H)
        if kind == "image":
            img.alpha_composite(Image.open(theme_dir / p["file"]).convert("RGBA"), (x, y))
        elif kind == "label":
            f = fonts[p["font"]]
            text = p["text"].replace("%02d", "%02d" % remaining)
            lx = x + ((int(p["width"]) - f.width(text)) // 2 if p.get("align") == "center" else 0)
            f.draw(img, lx, y + f.ascent, text, tuple(int(p["color"][i:i + 2], 16) for i in (1, 3, 5)))
        elif kind == "progress_bar":
            bar, hl = load_box(theme_dir, p["bar_style"]), load_box(theme_dir, p["highlight_style"])
            w, h = int(p["width"]), int(p["height"])
            lp, rp = pad(bar, "nw", "w", "sw", axis=0), pad(bar, "ne", "e", "se", axis=0)
            tp, bp = pad(bar, "nw", "n", "ne", axis=1), pad(bar, "sw", "s", "se", axis=1)
            draw_box(img, bar, x, y, w - lp - rp, h - tp - bp)
            barwidth = (w - lp - rp) * (total - remaining) // total
            draw_box(img, hl, x + lp, y + tp, barwidth, h - tp - bp)
        elif kind == "boot_menu":
            sel, item = load_box(theme_dir, p["selected_item_pixmap_style"]), load_box(theme_dir, p["item_pixmap_style"])
            ih, gap = int(p["item_height"]), int(p["item_spacing"])
            sl, sr = pad(sel, "nw", "w", "sw", axis=0), pad(sel, "ne", "e", "se", axis=0)
            st, sb = pad(sel, "nw", "n", "ne", axis=1), pad(sel, "sw", "s", "se", axis=1)
            it = pad(item, "nw", "n", "ne", axis=1)
            shown = (int(p["height"]) + gap - max(st, it) - max(sb, pad(item, "sw", "s", "se", axis=1))) // (ih + gap)
            cwidth = int(p["width"])
            scroll = len(entries) > shown
            if scroll:
                cwidth -= int(p["scrollbar_width"]) + int(p["scrollbar_left_pad"])
            f = fonts[p["item_font"]]
            for i, (title, classes) in enumerate(entries[:shown]):
                top = y + i * (ih + gap)
                is_sel = i == selected
                box, tpad = (sel, st) if is_sel else (item, it)
                draw_box(img, box, x, top + max(st, it) - tpad, cwidth - sl - sr, ih)
                for cls in classes:
                    icon = theme_dir / "icons" / f"{cls}.png"
                    if icon.exists():
                        ic = Image.open(icon).convert("RGBA")
                        img.alpha_composite(ic, (x + max(sl, 0), top + tpad + (ih - ic.height) // 2))
                        break
                tx = x + sl + int(p["icon_width"]) + int(p["item_icon_space"])
                base = top + tpad + (ih - (f.ascent + f.descent)) // 2 + f.ascent
                c = p["selected_item_color" if is_sel else "item_color"]
                f.draw(img, tx, base, title, tuple(int(c[k:k + 2], 16) for k in (1, 3, 5)))
            if scroll:
                sx = x + cwidth + int(p["scrollbar_left_pad"])
                th = int(p["height"]) * shown // len(entries)
                ImageDraw.Draw(img).rectangle((sx + 4, y, sx + 7, y + int(p["height"]) - 1), fill=FAINT)
                ImageDraw.Draw(img).rectangle((sx, y, sx + 11, y + th), fill=SAND)
    return img.convert("RGB")


def main():
    variants = {
        "telemetry": lambda d, E, E0: telemetry(d, E),
        "telemetry-sans": lambda d, E, E0: telemetry(d, E, sans=True),
        "horizon": lambda d, E, E0: horizon(d, E0),
        "splash": lambda d, E, E0: splash(d, E, E0),  # the Plymouth theme, not a GRUB one
    }
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("variant", nargs="*", help=", ".join(variants) + " (default: all)")
    ap.add_argument("--preview", action="store_true")
    args = ap.parse_args()
    for name in args.variant:
        if name not in variants:
            ap.error(f"unknown variant {name!r}")

    E0 = Image.open(WALLPAPER).convert("RGB")
    E = E0.resize((W, H), Image.LANCZOS)
    OUT.mkdir(exist_ok=True)
    for name in args.variant or variants:
        theme_dir = OUT / name
        shutil.rmtree(theme_dir, ignore_errors=True)
        theme_dir.mkdir()
        frame = variants[name](theme_dir, E, E0)
        print(f"built {theme_dir}")
        if args.preview and frame:
            frame.save(OUT / f"{name}-preview.png")
        elif args.preview:
            preview(theme_dir, ENTRIES).save(OUT / f"{name}-preview.png")
            preview(theme_dir, ENTRIES + BOOTNEXT).save(OUT / f"{name}-preview-bootnext.png")


if __name__ == "__main__":
    main()
