#!/usr/bin/env python3
"""
App Icon Generator for Smart Attendance Tracker
Run this script to generate PNG icons from the SVG template.

Requirements:
    pip install cairosvg pillow

Usage:
    python generate_icons.py
"""

import os
import sys

try:
    import cairosvg
    from PIL import Image
    HAS_DEPS = True
except ImportError:
    HAS_DEPS = False

# Icon sizes needed
SIZES = {
    'app_icon.png': 1024,
    'app_icon_foreground.png': 1024,
}

def generate_icons():
    if not HAS_DEPS:
        print("❌ Missing dependencies. Install them with:")
        print("   pip install cairosvg pillow")
        print("\nAlternatively, manually create these PNG files:")
        print("   - assets/icons/app_icon.png (1024x1024)")
        print("   - assets/icons/app_icon_foreground.png (1024x1024, with padding)")
        print("\nYou can use online tools like:")
        print("   - https://www.svgtopng.com/")
        print("   - https://cloudconvert.com/svg-to-png")
        return False

    script_dir = os.path.dirname(os.path.abspath(__file__))
    icons_dir = os.path.join(script_dir, 'assets', 'icons')
    svg_path = os.path.join(icons_dir, 'app_icon.svg')

    if not os.path.exists(svg_path):
        print(f"❌ SVG file not found: {svg_path}")
        return False

    print("🎨 Generating app icons...")

    # Generate main icon
    main_icon_path = os.path.join(icons_dir, 'app_icon.png')
    cairosvg.svg2png(
        url=svg_path,
        write_to=main_icon_path,
        output_width=1024,
        output_height=1024
    )
    print(f"   ✓ Created {main_icon_path}")

    # Generate foreground icon (for adaptive icons - just the inner content)
    # For adaptive icons, we need ~66% of the icon in the center
    foreground_path = os.path.join(icons_dir, 'app_icon_foreground.png')
    cairosvg.svg2png(
        url=svg_path,
        write_to=foreground_path,
        output_width=1024,
        output_height=1024
    )
    print(f"   ✓ Created {foreground_path}")

    print("\n✅ Icons generated successfully!")
    print("\nNext steps:")
    print("   1. Run: flutter pub get")
    print("   2. Run: dart run flutter_launcher_icons")
    print("   3. Build your app: flutter build apk --release")

    return True

if __name__ == '__main__':
    generate_icons()
