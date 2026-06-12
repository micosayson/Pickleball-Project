# Frontend — Flutter App

Flutter web and mobile client for the Pickleball (Plaqora) platform.

---

## Folder Structure

```
frontend/lib/
  core/
    config/         # App-wide config (e.g. SupabaseConfig)
    network/        # API layer
      api_client.dart     # Singleton Dio client — JWT, base URL, errors
      api_endpoints.dart  # All endpoint path constants
      api_exception.dart  # Typed HTTP error class
  features/
    auth/
      pages/        # Full screens (LoginPage, RegisterPage, OnboardingPage)
      widgets/      # Reusable UI components (AuthGate, AuthLoginForm, etc.)
      services/     # Logic that talks to Supabase Auth (AuthService)
    home/
      pages/        # Home / dashboard screens
    <feature>/      # Each new feature gets its own folder (same pattern)
      pages/
      widgets/
      services/     # Calls ApiClient.instance — never raw http
```

Each feature is **self-contained**: its pages, widgets, and services live together under `features/<feature>/`.

---

## Frontend vs Backend — What Goes Where

| Type of logic | Where it lives |
|---|---|
| UI screens, forms, navigation | Flutter `features/<feature>/pages/` & `widgets/` |
| Supabase **Auth** (login, register, sign out) | Flutter `features/auth/services/auth_service.dart` |
| Reading / writing **business data** (courts, events, matches, payments) | **FastAPI backend** via `ApiClient` — call `/api/v1/...` |
| Role checks, admin actions, sensitive business logic | **FastAPI backend** |
| App config (URLs, keys) | `core/config/supabase_config.dart` |
| HTTP client, endpoint constants, error types | `core/network/` |

### Rule of thumb
> If it touches **who the user is** → handle it in Flutter via Supabase Auth.  
> If it touches **what the user does** (book a court, join an event, submit a score) → call the FastAPI backend.

---

## Auth Pattern

Authentication is handled **client-side** via Supabase Auth:

- `AuthService` wraps `supabase_flutter` for `signIn`, `signUp`, `signOut`
- `AuthGate` (a `StreamBuilder`) listens to `auth.onAuthStateChange` and routes:
  - **Session active** → Home screen
  - **No session** → Onboarding / Login
- After login/register, explicitly navigate with `Navigator.pushAndRemoveUntil` to clear the stack

**Never** call Supabase Auth from the FastAPI backend for login/register flows. Supabase issues the JWT — FastAPI only **validates** it via middleware.

---

## Adding a New Feature

1. Create `lib/features/<feature>/` with `pages/`, `widgets/`, `services/` subfolders
2. **UI only?** → `pages/` and `widgets/` only
3. **Needs data from FastAPI?** → Add a `services/<feature>_service.dart` that uses `ApiClient.instance`:

```dart
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';

class EventsService {
  Future<List<dynamic>> getEvents() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.events);
      return response.data as List;
    } on ApiException {
      rethrow; // handle in UI
    }
  }
}
```

4. **Needs auth?** → Import `AuthService` or read `Supabase.instance.client.auth.currentUser`
5. **Register the route** in `main.dart` or the relevant navigator

---

## API Layer (`core/network/`)

The API layer is a shared tool that all feature services use to talk to the FastAPI backend.
**Never use raw `http` or `Dio` directly in a feature file** — always go through `ApiClient`.

### Files

| File | What it does |
|---|---|
| `api_client.dart` | Singleton Dio client — auto-attaches JWT, converts errors |
| `api_endpoints.dart` | All `/api/v1/...` path strings in one place |
| `api_exception.dart` | Typed error thrown on any HTTP failure |

---

### Making requests

```dart
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

// GET — fetch a list
final response = await ApiClient.instance.get(ApiEndpoints.events);

// GET — fetch a single item
final response = await ApiClient.instance.get(ApiEndpoints.event('abc-123'));

// GET — with query parameters
final response = await ApiClient.instance.get(
  ApiEndpoints.events,
  queryParameters: {'limit': 10, 'offset': 0},
);

// POST — create a resource
final response = await ApiClient.instance.post(
  ApiEndpoints.events,
  data: {'name': 'Thursday Open Play', 'court_id': 'xyz'},
);

// PUT — full update
final response = await ApiClient.instance.put(
  ApiEndpoints.event('abc-123'),
  data: {'name': 'Updated Name'},
);

// PATCH — partial update
final response = await ApiClient.instance.patch(
  ApiEndpoints.event('abc-123'),
  data: {'status': 'cancelled'},
);

// DELETE
await ApiClient.instance.delete(ApiEndpoints.event('abc-123'));
```

> The JWT token is **automatically attached** to every request.  
> The base URL (`http://localhost:8000/api/v1`) is set in `api_client.dart` — update it for production.

---

### Handling errors

`ApiClient` throws `ApiException` (never a raw `DioException`) on HTTP errors.

```dart
import '../../../core/network/api_exception.dart';

try {
  final response = await ApiClient.instance.get(ApiEndpoints.events);
  return response.data as List;
} on ApiException catch (e) {
  // e.statusCode → HTTP status code (401, 404, 500, etc.)
  // e.message    → raw server message
  // e.userMessage → safe, human-friendly string to show in the UI
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.userMessage)),
  );
}
```

---

### Adding a new endpoint

Open `api_endpoints.dart` and add a constant:

```dart
// Static path
static const String bookings = '/bookings';

// Dynamic path (with ID)
static String booking(String id) => '/bookings/$id';
```

Then use it anywhere:
```dart
ApiClient.instance.get(ApiEndpoints.bookings);
ApiClient.instance.get(ApiEndpoints.booking('my-id'));
```

---


## First Time Setup (New Developers)

After pulling this branch for the first time, run:

```powershell
flutter pub get
```

This downloads all dependencies listed in `pubspec.yaml` (including `supabase_flutter` and `dio`).
You do **not** need to install anything else — Flutter handles it automatically.

---

## Useful Commands

Run from `frontend/`:

```powershell
# Run on Chrome
flutter run -d chrome

# Hot reload (inside running session)
r

# Hot restart (inside running session)
R

# Get packages (run after every pubspec.yaml change)
flutter pub get
```


---

## Environment

- Supabase URL and Anon Key are in `lib/core/config/supabase_config.dart`
- Do **not** use the `SUPABASE_SERVICE_ROLE_KEY` in Flutter — that key is for the backend only
- Secrets for the backend live in `backend/.env` — never import those into Flutter
