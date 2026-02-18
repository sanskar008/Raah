#!/usr/bin/env python3
"""
Convert SVG app icons to PNG format.
Requires: pip install cairosvg pillow
"""

import os
import sys

try:
    import cairosvg
except ImportError:
    print("Error: cairosvg is not installed.")
    print("Please install it with: pip install cairosvg")
    sys.exit(1)

def convert_svg_to_png(svg_path, png_path, size=1024):
    """Convert SVG to PNG at specified size."""
    try:
        cairosvg.svg2png(
            url=svg_path,
            write_to=png_path,
            output_width=size,
            output_height=size
        )
        print(f"✓ Converted: {svg_path} → {png_path}")
        return True
    except Exception as e:
        print(f"✗ Error converting {svg_path}: {e}")
        return False

def main():
    # Get the project root directory (parent of scripts/)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    assets_icons_dir = os.path.join(project_root, "assets", "icons")
    
    # Ensure output directory exists
    os.makedirs(assets_icons_dir, exist_ok=True)
    
    # Convert main icon
    svg_main = os.path.join(assets_icons_dir, "app_icon.svg")
    png_main = os.path.join(assets_icons_dir, "app_icon.png")
    
    # Convert foreground icon
    svg_foreground = os.path.join(assets_icons_dir, "app_icon_foreground.svg")
    png_foreground = os.path.join(assets_icons_dir, "app_icon_foreground.png")
    
    print("Converting SVG icons to PNG...")
    print(f"Working directory: {assets_icons_dir}\n")
    
    success = True
    if os.path.exists(svg_main):
        success &= convert_svg_to_png(svg_main, png_main)
    else:
        print(f"✗ SVG file not found: {svg_main}")
        success = False
    
    if os.path.exists(svg_foreground):
        success &= convert_svg_to_png(svg_foreground, png_foreground)
    else:
        print(f"✗ SVG file not found: {svg_foreground}")
        success = False
    
    if success:
        print("\n✅ All icons converted successfully!")
        print("Now run: flutter pub run flutter_launcher_icons")
    else:
        print("\n❌ Some conversions failed.")
        sys.exit(1)

if __name__ == "__main__":
    main()
