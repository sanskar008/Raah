import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Simple script to generate app icon
/// Run with: dart scripts/generate_icon.dart
/// 
/// Note: This requires the 'image' package. Install with:
/// dart pub add image --dev

void main() {
  print('Generating app icon...');
  
  // Icon dimensions
  const size = 1024;
  const backgroundColor = 0xFF1A3C5E; // Navy blue
  const iconColor = 0xFFFFFFFF; // White
  
  // Create image with navy blue background
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgb8(
    (backgroundColor >> 16) & 0xFF,
    (backgroundColor >> 8) & 0xFF,
    backgroundColor & 0xFF,
  ));
  
  // Draw rounded rectangle background
  final radius = size ~/ 8; // Rounded corners
  img.fillRect(image, 
    x1: 0, y1: 0, x2: size - 1, y2: size - 1,
    radius: radius,
    color: img.ColorRgb8(
      (backgroundColor >> 16) & 0xFF,
      (backgroundColor >> 8) & 0xFF,
      backgroundColor & 0xFF,
    ),
  );
  
  // Draw simple home icon (simplified version)
  // This is a basic representation - you may want to use a proper icon
  final iconSize = size ~/ 2;
  final centerX = size ~/ 2;
  final centerY = size ~/ 2;
  
  // Draw house shape (simplified)
  // Roof (triangle)
  final roofPoints = [
    img.Point(centerX, centerY - iconSize ~/ 2),
    img.Point(centerX - iconSize ~/ 2, centerY - iconSize ~/ 4),
    img.Point(centerX + iconSize ~/ 2, centerY - iconSize ~/ 4),
  ];
  img.fillPolygon(image, roofPoints, color: img.ColorRgb8(255, 255, 255));
  
  // House body (rectangle)
  img.fillRect(image,
    x1: centerX - iconSize ~/ 3,
    y1: centerY - iconSize ~/ 4,
    x2: centerX + iconSize ~/ 3,
    y2: centerY + iconSize ~/ 2,
    color: img.ColorRgb8(255, 255, 255),
  );
  
  // Door
  img.fillRect(image,
    x1: centerX - iconSize ~/ 8,
    y1: centerY,
    x2: centerX + iconSize ~/ 8,
    y2: centerY + iconSize ~/ 2,
    color: img.ColorRgb8(
      (backgroundColor >> 16) & 0xFF,
      (backgroundColor >> 8) & 0xFF,
      backgroundColor & 0xFF,
    ),
  );
  
  // Save main icon
  final mainIconFile = File('assets/icons/app_icon.png');
  mainIconFile.parent.createSync(recursive: true);
  mainIconFile.writeAsBytesSync(img.encodePng(image));
  print('✓ Created: assets/icons/app_icon.png');
  
  // Create foreground icon (white home on transparent)
  final foregroundImage = img.Image(width: size, height: size);
  // Draw the same home icon but on transparent background
  final foregroundRoofPoints = [
    img.Point(centerX, centerY - iconSize ~/ 2),
    img.Point(centerX - iconSize ~/ 2, centerY - iconSize ~/ 4),
    img.Point(centerX + iconSize ~/ 2, centerY - iconSize ~/ 4),
  ];
  img.fillPolygon(foregroundImage, foregroundRoofPoints, color: img.ColorRgb8(255, 255, 255));
  
  img.fillRect(foregroundImage,
    x1: centerX - iconSize ~/ 3,
    y1: centerY - iconSize ~/ 4,
    x2: centerX + iconSize ~/ 3,
    y2: centerY + iconSize ~/ 2,
    color: img.ColorRgb8(255, 255, 255),
  );
  
  final foregroundIconFile = File('assets/icons/app_icon_foreground.png');
  foregroundIconFile.writeAsBytesSync(img.encodePng(foregroundImage));
  print('✓ Created: assets/icons/app_icon_foreground.png');
  
  print('\n✅ Icons generated successfully!');
  print('Now run: flutter pub run flutter_launcher_icons');
}
