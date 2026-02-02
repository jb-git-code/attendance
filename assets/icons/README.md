# App Icon Setup

## Quick Setup (Recommended)

The app already has **Android adaptive icons** configured using vector drawables. These work automatically without PNG files.

For a complete icon setup including iOS, follow these steps:

### Step 1: Generate PNG Icons

You need to create a 1024x1024 PNG icon. Options:

**Option A: Use the SVG file**
1. Open `assets/icons/app_icon.svg` in a browser or design tool
2. Export as 1024x1024 PNG
3. Save as `assets/icons/app_icon.png`
4. Also save as `assets/icons/app_icon_foreground.png`

**Option B: Use an online converter**
1. Go to https://www.svgtopng.com/ or https://cloudconvert.com/svg-to-png
2. Upload `assets/icons/app_icon.svg`
3. Set output size to 1024x1024
4. Download and save to `assets/icons/app_icon.png`

**Option C: Use Python (if installed)**
```bash
pip install cairosvg pillow
python generate_icons.py
```

### Step 2: Generate All Platform Icons

After creating the PNG file:

```bash
flutter pub get
dart run flutter_launcher_icons
```

This will generate icons for:
- Android (all densities)
- iOS (all sizes)
- Web
- macOS
- Windows

### Step 3: Rebuild the App

```bash
flutter clean
flutter build apk --release
```

## Icon Design

The icon features:
- **Indigo to Violet gradient** background (#6366F1 → #8B5CF6)
- **White calendar/clipboard** representing attendance tracking
- **Green checkmark** symbolizing successful attendance
- **Calendar dots** for visual appeal

This matches the app's production theme colors.

## Manual Android Icon (Already Configured)

The Android adaptive icon is already set up using vector drawables:
- Background: `android/app/src/main/res/drawable/ic_launcher_background.xml`
- Foreground: `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- Adaptive config: `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`

These will automatically work on Android 8.0+ devices.
