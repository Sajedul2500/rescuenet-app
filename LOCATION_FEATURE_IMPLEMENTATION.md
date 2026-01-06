# Location Service Implementation

## Overview

This document describes the implementation of device location service checking and enforcement throughout the RescueNet app.

## Key Changes

### 1. User Dashboard Page (`lib/pages/UserDashboardPage.dart`)

**Purpose**: Check and enforce location services whenever the app is opened or resumed from background.

**Key Features**:

- Checks device location service status using `Geolocator.isLocationServiceEnabled()`
- Verifies app has location permission using `Permission.location.status`
- Shows non-dismissible dialog if location is disabled
- Rechecks location when app resumes from background using `WidgetsBindingObserver`
- Guides users to enable location service in device settings
- Handles permanently denied permissions by opening app settings

**Location Check Flow**:

```
App Opens/Resumes
    ↓
Check if location service enabled on device
    ↓
├─ NO  → Show "Enable Location Service" dialog → Open device settings
└─ YES → Check app permission
           ↓
           ├─ Denied → Show "Enable Location" dialog → Request permission
           ├─ Permanently Denied → Open app settings
           └─ Granted → Allow app usage
```

### 2. Registration Step 3 (`lib/pages/RegistrationStep3Page.dart`)

**Purpose**: Request location services during user registration.

**Key Features**:

- Checks device location service before requesting permission
- Requests location permission from user
- Gets actual GPS coordinates using `Geolocator.getCurrentPosition()`
- Handles different permission states (granted, denied, permanently denied)
- Stores location data in SharedPreferences

**Registration Flow**:

```
User reaches Step 3
    ↓
Tap "Allow Location Access"
    ↓
Check device location service enabled
    ↓
├─ NO  → Show settings dialog → User enables service
└─ YES → Request app permission
           ↓
           Get GPS coordinates → Save to preferences → Continue to dashboard
```

### 3. Android Permissions (`android/app/src/main/AndroidManifest.xml`)

**Added Permissions**:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 4. iOS Permissions (`ios/Runner/Info.plist`)

**Added Keys**:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>RescueNet needs your location to send accurate emergency alerts and connect you with nearby volunteers and rescue teams.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>RescueNet needs your location to send accurate emergency alerts and connect you with nearby volunteers and rescue teams.</string>
```

## Dependencies

The following packages are used for location functionality:

```yaml
geolocator: ^11.0.0
permission_handler: ^11.2.0
```

## Implementation Details

### Location Service Check

```dart
// Check if device location service is enabled
final serviceEnabled = await Geolocator.isLocationServiceEnabled();

// Check app permission status
final permission = await Permission.location.status;
```

### Request Permission

```dart
// Request location permission
final status = await Permission.location.request();

if (status.isGranted) {
  // Get current position
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
```

### Open Settings

```dart
// Open device location settings
await Geolocator.openLocationSettings();

// Open app settings for permissions
await openAppSettings();
```

## User Experience Flow

### First Time User (Registration)

1. Complete Step 1 (basic info)
2. Complete/Skip Step 2 (NID verification)
3. Step 3: Prompted to enable location
4. If location service is OFF → Directed to device settings
5. If location service is ON → Permission requested
6. Permission granted → GPS coordinates obtained → Registration complete

### Existing User (Dashboard)

1. User opens app
2. Auto-login if session exists
3. Dashboard loads
4. Location check runs automatically
5. If location disabled → Non-dismissible dialog appears
6. User must enable location to use app
7. Dialog offers:
   - "Open Settings" button → Opens device/app settings
   - "I've Enabled It" button → Rechecks location

### Background to Foreground

1. User switches away from app
2. User returns to app
3. `didChangeAppLifecycleState` triggered with `resumed` state
4. Location check runs again
5. If location was disabled → Dialog appears

## Testing Scenarios

### Test Case 1: New User Registration

- Start registration process
- Verify location prompt appears at Step 3
- Test with location service ON and OFF
- Verify GPS coordinates are obtained when granted

### Test Case 2: Dashboard with Location ON

- Login to app
- Verify no location dialog appears
- Verify dashboard loads normally

### Test Case 3: Dashboard with Location OFF

- Turn off device location service
- Open app
- Verify non-dismissible dialog appears
- Verify dialog cannot be closed without enabling location

### Test Case 4: App Resume

- Open app with location ON
- Switch to another app
- Turn off location service
- Return to RescueNet app
- Verify location dialog appears automatically

### Test Case 5: Permanently Denied Permission

- Deny location permission
- Deny again when re-prompted
- Verify "Open App Settings" dialog appears
- Verify button opens device app settings

## Notes

### SharedPreferences Keys

- `locationEnabled`: Boolean flag indicating if location is enabled
- `userLocation`: String storing location description or coordinates

### Location Accuracy

The app uses `LocationAccuracy.high` for the most accurate GPS readings, which is essential for emergency response applications.

### Platform Differences

- **Android**: Requires both service check and permission check
- **iOS**: Location service is automatically enabled when permission is granted

### Non-Dismissible Dialogs

Location dialogs use `WillPopScope` (or `PopScope` in newer Flutter) with `onWillPop: () async => false` to prevent users from dismissing the dialog without taking action.

## Future Enhancements

1. **Background Location**: Implement background location tracking for active emergencies
2. **Location Updates**: Add periodic location updates during emergency situations
3. **Geofencing**: Implement geofencing for location-based alerts
4. **Location History**: Store location history for emergency response tracking
5. **Battery Optimization**: Add options for different location accuracy levels based on battery status

## Troubleshooting

### Location Not Working on Android

1. Check AndroidManifest.xml has required permissions
2. Verify device location service is enabled
3. Check app has location permission in Settings
4. For Android 10+, may need background location permission for certain features

### Location Not Working on iOS

1. Check Info.plist has location usage descriptions
2. Verify user granted permission when prompted
3. Check iOS Settings → Privacy → Location Services → RescueNet

### Dialog Not Appearing

1. Verify `WidgetsBindingObserver` is properly registered
2. Check `_checkLocationPermission()` is called in `initState`
3. Ensure `mounted` check is present before showing dialogs

## Support

For issues or questions about the location implementation, please contact the development team.
