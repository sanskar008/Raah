import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Flutter script to generate app icon with home emoji
/// Run with: flutter run -d chrome --target=scripts/generate_icon_emoji.dart
/// Or use: dart run scripts/generate_icon_emoji.dart (if using dart:ui directly)

void main() async {
  print('Generating app icon with home emoji...');
  
  const size = 1024.0;
  const backgroundColor = Color(0xFF1A3C5E); // Navy blue
  const emojiSize = 600.0;
  
  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
  
  // Draw rounded rectangle background
  final backgroundPaint = Paint()..color = backgroundColor;
  final roundedRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, size, size),
    const Radius.circular(128),
  );
  canvas.drawRRect(roundedRect, backgroundPaint);
  
  // Draw home emoji
  final textPainter = TextPainter(
    text: const TextSpan(
      text: '🏠',
      style: TextStyle(
        fontSize: emojiSize,
        fontFamily: 'Arial',
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );
  
  // Convert to image
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();
  
  // Save main icon
  final mainIconFile = File('assets/icons/app_icon.png');
  await mainIconFile.parent.create(recursive: true);
  await mainIconFile.writeAsBytes(pngBytes);
  print('✓ Created: assets/icons/app_icon.png');
  
  // Create foreground icon (white emoji on transparent)
  final foregroundRecorder = ui.PictureRecorder();
  final foregroundCanvas = Canvas(foregroundRecorder, Rect.fromLTWH(0, 0, size, size));
  
  final foregroundTextPainter = TextPainter(
    text: const TextSpan(
      text: '🏠',
      style: TextStyle(
        fontSize: emojiSize,
        fontFamily: 'Arial',
        color: Colors.white,
      ),
    ),
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );
  foregroundTextPainter.layout();
  foregroundTextPainter.paint(
    foregroundCanvas,
    Offset(
      (size - foregroundTextPainter.width) / 2,
      (size - foregroundTextPainter.height) / 2,
    ),
  );
  
  final foregroundPicture = foregroundRecorder.endRecording();
  final foregroundImage = await foregroundPicture.toImage(size.toInt(), size.toInt());
  final foregroundByteData = await foregroundImage.toByteData(format: ui.ImageByteFormat.png);
  final foregroundPngBytes = foregroundByteData!.buffer.asUint8List();
  
  final foregroundIconFile = File('assets/icons/app_icon_foreground.png');
  await foregroundIconFile.writeAsBytes(foregroundPngBytes);
  print('✓ Created: assets/icons/app_icon_foreground.png');
  
  print('\n✅ Icons generated successfully!');
  print('Now run: flutter pub run flutter_launcher_icons');
  
  exit(0);
}
