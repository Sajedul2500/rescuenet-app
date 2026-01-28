# RescueNet APK Build Configuration

## ✅ Issues Fixed

### 1. Network Connectivity Issues

- ✅ Added `INTERNET` and `ACCESS_NETWORK_STATE` permissions to AndroidManifest.xml
- ✅ Created `network_security_config.xml` to allow HTTP cleartext traffic
- ✅ Added `usesCleartextTraffic="true"` to application tag
- ✅ Configured domains: 110.76.128.74, 192.168.68.119, localhost, 10.0.2.2
- ✅ Base URL configured: http://110.76.128.74:8777/api/v1

### 2. Multipart File Upload Issues

- ✅ Added camera and storage permissions (READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE, READ_MEDIA_IMAGES, READ_MEDIA_VIDEO)
- ✅ Multipart implementation using Dio FormData with proper content-type headers
- ✅ Files uploaded with `files[]` array notation
- ✅ Proper filename handling for images and videos

### 3. Build Configuration

- ✅ compileSdk: 34
- ✅ minSdk: 21
- ✅ targetSdk: 34
- ✅ versionCode: 2
- ✅ versionName: 1.0.1
- ✅ multiDexEnabled: true
- ✅ Java 17 compatibility
- ✅ Gradle optimization enabled (daemon, parallel, caching)

## 📋 Permissions Granted

### Required Permissions:

1. INTERNET - Network communication
2. ACCESS_NETWORK_STATE - Check network status
3. ACCESS_FINE_LOCATION - GPS location
4. ACCESS_COARSE_LOCATION - Network location
5. CAMERA - Take photos/videos
6. READ_EXTERNAL_STORAGE - Access media files
7. WRITE_EXTERNAL_STORAGE - Save files (SDK < 33)
8. READ_MEDIA_IMAGES - Access images (SDK 33+)
9. READ_MEDIA_VIDEO - Access videos (SDK 33+)

## 🔧 Files Modified/Created

1. `/android/app/src/main/res/xml/network_security_config.xml` - NEW
2. `/android/app/src/main/AndroidManifest.xml` - UPDATED
3. `/android/app/build.gradle.kts` - UPDATED
4. `/android/gradle.properties` - UPDATED

## 🚀 Build Instructions

### Option 1: Using Build Script

```bash
chmod +x build_apk.sh
./build_apk.sh
```

### Option 2: Manual Build

```bash
# Clean
flutter clean
rm -rf build/

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release
```

### Option 3: Split APKs (smaller size)

```bash
flutter build apk --split-per-abi --release
```

## 📱 Output Location

**Release APK:**
`build/app/outputs/flutter-apk/app-release.apk`

**Split APKs (if using --split-per-abi):**

- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (Intel 64-bit)

## 🧪 Testing Checklist

After installing the APK, test:

- [ ] App launches successfully
- [ ] Registration flow works (3 steps)
- [ ] Login with credentials
- [ ] Dashboard loads data from server
- [ ] Create help request with location
- [ ] Upload images to help request
- [ ] Upload video to help request
- [ ] View help request details
- [ ] Flag report feature
- [ ] Emergency contacts CRUD operations
- [ ] Nearby volunteers with location
- [ ] Notifications
- [ ] Profile verification upload

## ⚠️ Troubleshooting

### If "No Internet Connection" persists:

1. Check if device can ping `110.76.128.74:8777`
2. Verify server is running and accessible
3. Try using local IP (192.168.68.119) if on same network
4. Check device WiFi/Mobile data is enabled

### If File Upload Fails:

1. Grant storage permissions in device settings
2. Grant camera permission for taking photos
3. Check file size limits on server
4. Verify server accepts multipart/form-data

### If Location Not Working:

1. Enable GPS/Location services on device
2. Grant location permission in app settings
3. Try outdoor location for better GPS signal

## 📝 Server Configuration

Current server endpoint: `http://110.76.128.74:8777/api/v1`

To change server URL, edit:
`lib/core/api/api_config.dart`

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:PORT/api/v1';
```

Then rebuild the APK.

## 🔐 Release Signing (Future)

For production release, create a keystore:

```bash
keytool -genkey -v -keystore ~/rescuenet-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias rescuenet
```

Then update `android/app/build.gradle.kts` with signing config.
