# RescueNet AI Coding Agent Instructions

## Project Overview

RescueNet is an emergency response Flutter app connecting users with rescue services. This is a final-year academic project being actively refactored from legacy page-based architecture to clean feature-based architecture.

## Critical Architecture Context

### 🚨 Active Migration State

The codebase is in **TRANSITION**:

- **Legacy**: `lib/pages/` - Contains old monolithic screens (LoginPage.dart, CreateRequestPage.dart, etc.)
- **Target**: `lib/features/` - New feature-based modules with data/domain/presentation layers
- **Status**: Dashboard, auth, emergency_services, emergency_guidance modules partially migrated

**When modifying code:**

- New features → MUST use `lib/features/<feature>/` structure
- Existing pages → Refactor to features when touching them substantially
- Quick fixes → Can stay in pages/, but flag for migration

### Feature-Based Structure (Mandatory for New Code)

```
lib/features/<feature>/
  ├── data/           # API calls, repository implementations
  ├── domain/         # Entities, abstract repos, services
  └── presentation/   # Widgets, screens, viewmodels
```

Example: `lib/features/dashboard/presentation/viewmodels/dashboard_header_viewmodel.dart`

## Core System Patterns

### 1. API Service Layer (`lib/core/api/`)

**All API calls go through ApiService with ApiResponse wrapper:**

```dart
final response = await _apiService.get<UserProfile>(
  ApiConfig.profile,
  parser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
);

if (response.success) {
  // Use response.data
}
```

**Key files:**

- `api_service.dart` - Dio-based HTTP client with auto token injection
- `api_config.dart` - Endpoint constants (baseUrl: `http://110.76.128.74:8777/api/v1`)
- `api_response.dart` - Unified response wrapper

**Pattern:** Never call HTTP directly. Always use ApiService with typed parsers.

### 2. Authentication & Storage

- **Token management**: `lib/core/storage/auth_storage.dart` uses flutter_secure_storage
- **Auto-injection**: ApiService interceptor adds `Bearer` token to all requests
- **Multi-step registration**: Tokens persist across registration steps (step1 → step2 → step3)

### 3. State Management

**Current approach: Provider + ChangeNotifier**

```dart
class DashboardHeaderViewModel extends ChangeNotifier {
  // Business logic here
  void updateState() {
    _state = newState;
    notifyListeners();
  }
}
```

**Rules:**

- ViewModels MUST extend ChangeNotifier (not Riverpod yet)
- ViewModels live in `features/<feature>/presentation/viewmodels/`
- UI binds via `ChangeNotifierProvider` or direct instantiation
- No BuildContext in business logic

### 4. App Startup Flow

Critical routing logic chain:

1. `main.dart` → RegistrationGuard
2. `registration_guard.dart` checks backend `/register/status` (single source of truth)
3. Routes to: WelcomePage | RegistrationStep1/2/3 | UserDashboardPage

**Why this matters:** User state is backend-driven. Don't cache registration status assumptions locally beyond the guard.

### 5. User Verification System

**New pattern (as of latest changes):**

- Check `UserProfile.isVerified` before critical actions (e.g., CreateRequestPage)
- Use `UserProfileService` to fetch profile: `await _profileService.getProfile()`
- Block unverified users with clear dialogs explaining verification requirements

**Example implementation:** See `CreateRequestPage.dart` lines 62-160 for verification check pattern.

## Common Tasks & Patterns

### Adding a New Feature Module

```bash
lib/features/my_feature/
  ├── data/services/my_feature_service.dart       # API calls
  ├── domain/models/my_feature_model.dart         # Data models
  ├── presentation/
      ├── screens/my_feature_screen.dart          # UI screens
      ├── widgets/my_feature_widget.dart          # Reusable components
      └── viewmodels/my_feature_viewmodel.dart    # Business logic
```

### Working with Forms & Validation

**Existing pattern in pages/:**

- Use `_formKey = GlobalKey<FormState>()`
- TextFormField with inline validators
- Submit only after `_formKey.currentState!.validate()`

**Best practice:** Migrate validation logic to ViewModels for testability.

### File Upload Pattern

```dart
final formData = FormData.fromMap({
  'field': 'value',
  'files[]': await MultipartFile.fromFile(path, filename: 'file.jpg'),
});

final response = await _apiService.postMultipart<ResponseType>(
  '/endpoint',
  data: formData,
  parser: (data) => ResponseType.fromJson(data),
);
```

See: `CreateRequestPage.dart` lines 270-300 for image/video upload example.

### Location Services

**Pattern:**

1. Request permission: `await Permission.location.request()`
2. Get position: `await Geolocator.getCurrentPosition()`
3. Geocode (optional): Use `GeocodingService.getPlaceFromCoordinates()`

**Location always required for help requests.**

## Project-Specific Conventions

### Naming

- ViewModels: `<Feature><Purpose>ViewModel` (e.g., DashboardHeaderViewModel)
- Services: `<Feature>Service` (e.g., UserProfileService)
- Models: Descriptive nouns (e.g., UserProfile, DashboardHeaderState)

### Error Handling

**Preferred pattern:**

```dart
try {
  final response = await _apiService.get(...);
  if (response.success) {
    // Handle success
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Error')),
    );
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.toString()}')),
  );
}
```

### UI Consistency

- Primary color: `Color(0xFFD32F2F)` (red theme)
- Font: Google Fonts Poppins (already configured globally)
- Spacing: Multiples of 4 or 8 (8, 12, 16, 20, etc.)

## Key Files to Reference

### Core Infrastructure

- `lib/core/api/api_service.dart` - All HTTP logic
- `lib/core/guards/registration_guard.dart` - Startup routing logic
- `lib/core/storage/auth_storage.dart` - Secure token storage

### Service Layer Examples

- `lib/services/user_profile_service.dart` - Profile/verification APIs
- `lib/features/registration/data/services/registration_service.dart` - Multi-step registration

### ViewModel Examples

- `lib/features/dashboard/presentation/viewmodels/dashboard_header_viewmodel.dart` - Clean ViewModel pattern
- Uses ChangeNotifier, dependency injection, proper separation

### Migration Reference

Compare:

- Old: `lib/pages/CreateRequestPage.dart` (monolithic, direct API)
- New: `lib/features/dashboard/` (layered, separated concerns)

## Testing Strategy

**Current state:** No tests yet (academic project)
**Preparation for tests:**

- Inject dependencies (ApiService, storage) into services
- Use abstract repository interfaces in domain layer
- Keep business logic in ViewModels, not widgets

## Common Pitfalls

### ❌ Don't

- Call APIs directly from widgets (use services)
- Store sensitive data in SharedPreferences (use AuthStorage/flutter_secure_storage)
- Navigate with `Navigator.pushNamed` without checking auth state
- Hardcode API URLs (use ApiConfig constants)
- Create god widgets over 200 lines (extract widgets/viewmodels)

### ✅ Do

- Check user verification status before critical actions
- Use ApiResponse wrapper for consistent error handling
- Inject services/dependencies for testability
- Document complex business logic with comments
- Follow the feature-based structure for new code

## External Dependencies

Key packages (see pubspec.yaml):

- `dio` - HTTP client (wrapped by ApiService)
- `flutter_secure_storage` - Token storage
- `geolocator` + `permission_handler` - Location services
- `image_picker` - File uploads
- `google_fonts` - Typography

## Backend Integration

**Base URL:** `http://110.76.128.74:8777/api/v1`
**Auth:** Bearer token in Authorization header (auto-injected)
**Key endpoints:** See `lib/core/api/api_config.dart` for full list

---

**Remember:** This is an academic project under active development. Code quality and architecture matter more than speed. When in doubt, favor maintainability and clear separation of concerns.
