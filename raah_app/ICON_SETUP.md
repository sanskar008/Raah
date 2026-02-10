# App Icon Setup Guide

## ✅ App Name Updated
- **Android**: Set to "Raah" ✓
- **iOS**: Set to "Raah" ✓

## 🎨 Icon Design
The app icon matches your login page design:
- **Background**: Navy blue (#1A3C5E) with rounded corners
- **Icon**: White home icon (Material Icons: home_rounded style)
- **Style**: Clean, modern, matches your app's design language

## 📱 Quick Setup (3 Steps)

### Step 1: Convert SVG to PNG
I've created SVG templates in `assets/icons/`:
- `app_icon.svg` - Full icon with background
- `app_icon_foreground.svg` - Icon only (for adaptive icon)

**Convert to PNG:**
1. Open the SVG files in any image editor (Photoshop, GIMP, Inkscape, or online tool)
2. Export as PNG at 1024x1024 pixels
3. Save as:
   - `assets/icons/app_icon.png` (1024x1024)
   - `assets/icons/app_icon_foreground.png` (1024x1024)

**Or use online converter:**
- Go to https://cloudconvert.com/svg-to-png
- Upload `app_icon.svg` → Convert to PNG → Download
- Rename to `app_icon.png` and place in `assets/icons/`
- Repeat for `app_icon_foreground.svg`

### Step 2: Install Dependencies
```bash
cd raah_app
flutter pub get
```

### Step 3: Generate Icons
```bash
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for:
- ✅ Android (all densities: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ iOS (all required sizes)
- ✅ Adaptive icons for Android

## 🎯 Alternative: Use Online Icon Generator

If you prefer, you can use an online tool:

1. **Go to**: https://www.appicon.co/ or https://icon.kitchen/
2. **Upload**: A 1024x1024 PNG with:
   - Navy blue (#1A3C5E) rounded square background
   - White home icon in center (like your login page)
3. **Download**: Generated icon pack
4. **Place**: Main icon as `assets/icons/app_icon.png`
5. **Run**: `flutter pub run flutter_launcher_icons`

## ✨ Icon Specifications

- **Size**: 1024x1024 pixels
- **Format**: PNG with transparency
- **Background Color**: #1A3C5E (Navy blue)
- **Icon Color**: #FFFFFF (White)
- **Corner Radius**: ~128px (rounded square)
- **Icon Style**: Material home_rounded icon

## 🔍 Verify

After generating icons:
- **Android**: Check `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **iOS**: Check `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

The app will now show "Raah" as the name with your home icon! 🏠
