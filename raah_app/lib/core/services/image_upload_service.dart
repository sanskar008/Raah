import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service for uploading images to Cloudinary (free tier: 25GB storage, 25GB bandwidth/month)
/// 
/// Setup Instructions:
/// 1. Sign up for free at https://cloudinary.com/users/register_free
/// 2. Get your Cloud Name from Dashboard
/// 3. Create an "Unsigned" upload preset named "raah_properties"
/// 4. Add your Cloud Name below
/// 
/// See CLOUDINARY_SETUP.md for detailed instructions
class ImageUploadService {
  // ── Cloudinary Configuration ──
  // Using unsigned uploads (no API key/secret needed)
  static const String _cloudName = 'dmoqbdyxa';
  static const String _uploadPreset = 'matrimony_unsigned';

  /// Upload a single image file to Cloudinary
  /// Returns the secure URL of the uploaded image
  static Future<String> uploadImage(File imageFile) async {
    try {
      debugPrint('📤 Uploading image to Cloudinary...');
      
      // Create multipart request
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add upload preset (for unsigned uploads - safer for client-side)
      request.fields['upload_preset'] = _uploadPreset;
      
      // Optional: Add folder to organize images
      request.fields['folder'] = 'raah/properties';

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['secure_url'] as String;
        
        debugPrint('✅ Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('❌ Upload failed: ${response.statusCode} - ${response.body}');
        throw Exception('Unable to upload image. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Image upload error: $e');
      // Re-throw with friendly message if it's not already an Exception with message
      if (e is Exception && e.toString().contains('Exception')) {
        throw Exception('Unable to upload image. Please check your internet connection and try again.');
      }
      rethrow;
    }
  }

  /// Upload multiple images
  /// Returns list of uploaded image URLs
  static Future<List<String>> uploadImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];
    
    for (var i = 0; i < imageFiles.length; i++) {
      try {
        debugPrint('📤 Uploading image ${i + 1}/${imageFiles.length}...');
        final url = await uploadImage(imageFiles[i]);
        uploadedUrls.add(url);
      } catch (e) {
        debugPrint('❌ Failed to upload image ${i + 1}: $e');
        // Continue with other images even if one fails
      }
    }
    
    return uploadedUrls;
  }

  /// Check if Cloudinary is configured
  static bool isConfigured() {
    return _cloudName != 'YOUR_CLOUD_NAME' && 
           _cloudName.isNotEmpty &&
           _uploadPreset.isNotEmpty;
  }
}
