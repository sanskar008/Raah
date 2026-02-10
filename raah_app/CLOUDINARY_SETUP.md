# Cloudinary Image Upload Setup Guide

This app uses **Cloudinary** (free tier) for image storage. Follow these steps to set it up:

## 🆓 Free Tier Benefits
- **25GB storage** (plenty for property images)
- **25GB bandwidth/month** (free data transfer)
- No credit card required
- Perfect for development and small apps

## 📋 Setup Steps

### 1. Create a Free Cloudinary Account
1. Go to [https://cloudinary.com/users/register_free](https://cloudinary.com/users/register_free)
2. Sign up with your email (it's free!)
3. Verify your email address

### 2. Get Your Credentials
1. After logging in, go to your [Dashboard](https://cloudinary.com/console)
2. You'll see your **Cloud Name**, **API Key**, and **API Secret**
3. Copy these values (you'll need them in step 3)

### 3. Create an Upload Preset
1. In Cloudinary Dashboard, go to **Settings** → **Upload**
2. Scroll down to **Upload presets**
3. Click **Add upload preset**
4. Name it: `raah_properties`
5. Set **Signing mode** to: **Unsigned** (this allows client-side uploads)
6. Click **Save**

### 4. Configure the App
1. Open `raah_app/lib/core/services/image_upload_service.dart`
2. Replace these values with your Cloudinary credentials:

```dart
static const String _cloudName = 'YOUR_CLOUD_NAME'; // e.g., 'dxyz123abc'
static const String _apiKey = 'YOUR_API_KEY'; // e.g., '123456789012345'
static const String _uploadPreset = 'raah_properties'; // Keep this as is
```

**Example:**
```dart
static const String _cloudName = 'dxyz123abc';
static const String _apiKey = '123456789012345';
static const String _uploadPreset = 'raah_properties';
```

> **Note:** For production apps, you should store these in environment variables or a secure config file. For now, this works fine for development.

### 5. Test It!
1. Run your app
2. Go to "Add Property" screen
3. Tap "Add images" and select photos
4. Submit the property
5. Images should upload to Cloudinary automatically!

## 🔒 Security Note

The current setup uses **unsigned uploads** which is fine for development. For production:
- Consider using signed uploads with server-side authentication
- Or use Cloudinary's upload widget with signed requests
- Never expose your API Secret in client-side code

## 📸 How It Works

1. User selects images from their device
2. Images are uploaded to Cloudinary
3. Cloudinary returns secure URLs (HTTPS)
4. URLs are saved to your database
5. Images are displayed in your app using these URLs

## ❓ Troubleshooting

**"Cloudinary not configured" error:**
- Make sure you've updated the credentials in `image_upload_service.dart`
- Verify your Cloud Name and API Key are correct
- Ensure the upload preset name matches exactly: `raah_properties`

**Upload fails:**
- Check your internet connection
- Verify the upload preset is set to "Unsigned"
- Check Cloudinary dashboard for any account limits

**Images not showing:**
- Verify the URLs are being saved to the database
- Check that image URLs start with `https://res.cloudinary.com/`

## 🎉 That's It!

Your image upload system is now ready! All property images will be stored on Cloudinary's free tier.
