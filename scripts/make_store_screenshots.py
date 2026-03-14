#!/usr/bin/env python3
"""
Generates Play Store decorated screenshots for Entre Sets.
Canvas: 1080 × 2640 (300px branded header + 2340px screenshot)
"""

from PIL import Image, ImageDraw, ImageFont
import os

# ── Paths ────────────────────────────────────────────────────────────────────
BASE   = "/Users/hugomatsumoto/Projects/HMLabs/TennisProjects/tennis-tournament"
SRC    = f"{BASE}/assets/Screenshots"
OUT    = f"{BASE}/assets/StoreScreenshots"
os.makedirs(OUT, exist_ok=True)

# ── Brand palette ─────────────────────────────────────────────────────────────
BLACK     = (13,  13,  13)
DARK      = (24,  24,  24)
MID_DARK  = (36,  36,  36)
LIME      = (204, 255,   0)
GOLD      = (255, 184,   0)
WHITE     = (255, 255, 255)
LIGHT     = (200, 200, 200)
DIM       = (100, 100, 100)

# ── Canvas dimensions ─────────────────────────────────────────────────────────
W         = 1080
HDR       = 300      # header height
SCR_H     = 2340     # screenshot height
TOTAL_H   = HDR + SCR_H  # 2640

# ── Shots to produce ─────────────────────────────────────────────────────────
SHOTS = [
    {
        "src":     "Screenshot_20260314_135216.jpg",
        "num":     "01",
        "tagline": "Descubra\nTorneios",
        "sub":     "Simples · Duplas · Open Tennis",
        "accent":  LIME,
        "out":     "store_01_tournaments.jpg",
    },
    {
        "src":     "Screenshot_20260314_135327.jpg",
        "num":     "02",
        "tagline": "Classificação\nem Tempo Real",
        "sub":     "Grupos, pontos e resultados",
        "accent":  LIME,
        "out":     "store_02_standings.jpg",
    },
    {
        "src":     "Screenshot_20260314_135227.jpg",
        "num":     "03",
        "tagline": "Sua Agenda\nde Partidas",
        "sub":     "Horários, quadras e adversários",
        "accent":  GOLD,
        "out":     "store_03_schedule.jpg",
    },
    {
        "src":     "Screenshot_20260314_135822.jpg",
        "num":     "04",
        "tagline": "Celebre\nCada Vitória",
        "sub":     "Compartilhe seus resultados",
        "accent":  GOLD,
        "out":     "store_04_winner.jpg",
    },
]

# ── Font helpers ──────────────────────────────────────────────────────────────
_FONT_PATHS = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/HelveticaNeue.ttc",
    "/System/Library/Fonts/Helvetica.ttc",
]
_FONT_REG_PATHS = [
    "/System/Library/Fonts/Supplemental/Arial.ttf",
    "/System/Library/Fonts/HelveticaNeue.ttc",
]

def bold(size):
    for p in _FONT_PATHS:
        try: return ImageFont.truetype(p, size)
        except: pass
    return ImageFont.load_default()

def reg(size):
    for p in _FONT_REG_PATHS:
        try: return ImageFont.truetype(p, size)
        except: pass
    return ImageFont.load_default()

# ── Draw helpers ──────────────────────────────────────────────────────────────
def gradient_rect(draw, x0, y0, x1, y1, c_top, c_bot):
    """Vertical linear gradient fill."""
    for y in range(y0, y1):
        t  = (y - y0) / max(y1 - y0, 1)
        r  = int(c_top[0] + (c_bot[0] - c_top[0]) * t)
        g  = int(c_top[1] + (c_bot[1] - c_top[1]) * t)
        b  = int(c_top[2] + (c_bot[2] - c_top[2]) * t)
        draw.line([(x0, y), (x1, y)], fill=(r, g, b))

def blend_fade(img, fade_h=80):
    """Adds a top-to-transparent fade over the top `fade_h` rows of `img`."""
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw    = ImageDraw.Draw(overlay)
    for y in range(fade_h):
        alpha = int(255 * (1 - y / fade_h))
        draw.line([(0, y), (W, y)], fill=(13, 13, 13, alpha))
    base = img.convert("RGBA")
    return Image.alpha_composite(base, overlay).convert("RGB")

def dot_grid(draw, cx, cy, rows, cols, spacing, r, color, alpha_base=60):
    """Draw a grid of semi-transparent dots."""
    for row in range(rows):
        for col in range(cols):
            x  = cx + col * spacing
            y  = cy + row * spacing
            a  = min(255, alpha_base + (row + col) * 18)
            c  = (*color, a)
            # PIL needs RGBA mode for alpha on ellipse – we simulate with a fixed colour
            bright = tuple(int(ch * a / 255) for ch in color)
            draw.ellipse([x-r, y-r, x+r, y+r], fill=bright)

# ── Main render ───────────────────────────────────────────────────────────────
def render(shot):
    accent  = shot["accent"]
    dim_acc = tuple(int(c * 0.35) for c in accent)   # dimmed accent for bg glow
    hi_acc  = tuple(min(255, int(c * 1.05)) for c in accent)

    # ── Canvas ────────────────────────────────────────────────────────────────
    canvas = Image.new("RGB", (W, TOTAL_H), BLACK)
    draw   = ImageDraw.Draw(canvas)

    # ── Header background: dark gradient ──────────────────────────────────────
    gradient_rect(draw, 0, 0, W, HDR, DARK, BLACK)

    # Subtle radial-ish glow in bottom-left of header (low-key accent colour)
    glow_x, glow_y, glow_r = 60, HDR, 260
    for ring in range(glow_r, 0, -6):
        t     = ring / glow_r
        alpha = int(28 * (1 - t))
        col   = tuple(int(dim_acc[i] * alpha / 28) for i in range(3))
        draw.ellipse(
            [glow_x - ring, glow_y - ring, glow_x + ring, glow_y + ring],
            fill=col,
        )

    # ── Top accent rule (full width) ──────────────────────────────────────────
    draw.rectangle([0, 0, W, 4], fill=accent)

    # ── Left vertical accent bar ──────────────────────────────────────────────
    BAR_X  = 60
    draw.rectangle([BAR_X, 28, BAR_X + 5, HDR - 28], fill=accent)

    # ── Ghost number (decorative, top-right) ──────────────────────────────────
    f_ghost = bold(220)
    ghost_text = shot["num"]
    bb = draw.textbbox((0, 0), ghost_text, font=f_ghost)
    gw, gh = bb[2] - bb[0], bb[3] - bb[1]
    ghost_x = W - gw - 30
    ghost_y = (HDR - gh) // 2 - 10
    # dim the accent colour to ~12% for the ghost
    ghost_col = tuple(int(c * 0.12) for c in accent)
    draw.text((ghost_x, ghost_y), ghost_text, font=f_ghost, fill=ghost_col)

    # ── "ENTRE SETS" label ────────────────────────────────────────────────────
    f_brand = bold(22)
    draw.text((BAR_X + 18, 32), "ENTRE SETS", font=f_brand, fill=DIM)

    # ── Tagline ───────────────────────────────────────────────────────────────
    f_tag = bold(76)
    draw.multiline_text(
        (BAR_X + 18, 60),
        shot["tagline"],
        font=f_tag,
        fill=WHITE,
        spacing=6,
    )

    # ── Subline ───────────────────────────────────────────────────────────────
    f_sub = reg(28)
    draw.text((BAR_X + 18, HDR - 56), shot["sub"], font=f_sub, fill=hi_acc)

    # ── Dot grid (top-right decorative) ───────────────────────────────────────
    dot_grid(draw, W - 160, 24, 4, 4, 26, 5, accent, alpha_base=50)

    # ── Screenshot ────────────────────────────────────────────────────────────
    scr = Image.open(f"{SRC}/{shot['src']}")
    scr = blend_fade(scr, fade_h=60)          # soft top-fade to merge with header
    canvas.paste(scr, (0, HDR))

    # ── Bottom gradient fade + subline bar ────────────────────────────────────
    BAR_BOT_H = 90
    by0 = TOTAL_H - BAR_BOT_H
    gradient_rect(draw, 0, by0, W, TOTAL_H, (0, 0, 0, 0), BLACK)
    draw.rectangle([0, by0, W, by0 + 4], fill=accent)

    # ── Save ──────────────────────────────────────────────────────────────────
    out_path = f"{OUT}/{shot['out']}"
    canvas.save(out_path, "JPEG", quality=95, optimize=True)
    print(f"  ✓  {shot['out']}")

# ── Run ───────────────────────────────────────────────────────────────────────
print("Rendering Play Store screenshots…\n")
for s in SHOTS:
    render(s)
print(f"\nDone → {OUT}/")
