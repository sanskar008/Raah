# App Icon Setup Instructions

## Icon Design
The app icon should match the login page design:
- **Background**: Navy blue (#1A3C5E) - rounded square
- **Icon**: White home icon (Material Icons: home_rounded)
- **Size**: 1024x1024 pixels (for app icon generation)

## Quick Setup

### Option 1: Use Online Icon Generator
1. Go to https://www.appicon.co/ or https://icon.kitchen/
2. Upload a 1024x1024 PNG image with:
   - Navy blue (#1A3C5E) rounded square background
   - White home icon in the center
3. Download the generated icons
4. Place the main icon as `assets/icons/app_icon.png`
5. Place the foreground icon (white home icon on transparent) as `assets/icons/app_icon_foreground.png`

### Option 2: Create Manually
1. Create a 1024x1024 PNG image:
   - Background: Navy blue (#1A3C5E) with rounded corners
   - Center: White home icon (similar to login page)
2. Save as `assets/icons/app_icon.png`
3. Create a 1024x1024 PNG with just the white home icon on transparent background
4. Save as `assets/icons/app_icon_foreground.png`

### Option 3: Use Flutter Icon Generator Script
Run the provided script to generate a simple icon programmatically.

## After Creating Icons
Run this command to generate all app icons:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for Android and iOS.
