# Developer Run and Test Instructions

This document explains how another developer can set up, run, and test the
Pickleball Platform locally.

## Project Structure

```text
Pickleball-Project/
  backend/     FastAPI API, SQLAlchemy models, Alembic migrations
  frontend/    Flutter mobile/web client
  supabase/    Supabase SQL migrations
  docs/        Project documentation
```

## Requirements

- PowerShell
- Python 3.11 or newer
- Flutter SDK
- Android SDK/emulator if testing Android
- Java JDK 21 if building Android APKs
- Access to the project's Supabase URL, anon/publishable key, service role key,
  and database connection string

Do not commit `.env` files, Supabase passwords, service role keys, or user
credentials.

## Backend Setup

Open PowerShell in:

```powershell
G:\PickleProject\Pickleball-Project\backend
```

Create and install the backend virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
```

Create a local `backend\.env` file:

```powershell
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_or_publishable_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
DATABASE_URL=your_supabase_postgres_connection_string
```

Run database migrations:

```powershell
.\.venv\Scripts\python.exe -m alembic upgrade head
```

Optional: seed demo data:

```powershell
.\.venv\Scripts\python.exe scripts\seed_demo.py
```

Start the backend API:

```powershell
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Verify the backend is running:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
```

## Backend Tests

Run from `backend/`:

```powershell
.\.venv\Scripts\python.exe -m pytest
```

## Frontend Setup

Open a second PowerShell window in:

```powershell
G:\PickleProject\Pickleball-Project\frontend
```

Install Flutter packages:

```powershell
D:\Tools\flutter\bin\flutter.bat pub get
```

If Flutter is already on PATH, this also works:

```powershell
flutter pub get
```

## Run Flutter on Web

Use this when testing in Chrome on the same machine as the backend:

```powershell
D:\Tools\flutter\bin\flutter.bat run -d chrome --dart-define=BACKEND_BASE_URL=http://localhost:8000/api/v1 --dart-define=SUPABASE_PUBLISHABLE_KEY=your_supabase_anon_or_publishable_key
```

For web, `localhost` can reach the backend running on the same computer.

## Run Flutter on Android Emulator

Use `10.0.2.2` for the backend URL because Android emulators cannot reach the
host machine through `localhost`.

```powershell
D:\Tools\flutter\bin\flutter.bat run -d emulator --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000/api/v1 --dart-define=SUPABASE_PUBLISHABLE_KEY=your_supabase_anon_or_publishable_key
```

If Android builds fail because Java is not configured, set `JAVA_HOME` first:

```powershell
$env:JAVA_HOME='D:\Tools\jdk-21'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
```

## Build Debug APK

Run from `frontend/`:

```powershell
$env:JAVA_HOME='D:\Tools\jdk-21'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
D:\Tools\flutter\bin\flutter.bat build apk --debug --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000/api/v1 --dart-define=SUPABASE_PUBLISHABLE_KEY=your_supabase_anon_or_publishable_key
```

Install the APK on a connected emulator/device:

```powershell
D:\Tools\Android\Sdk\platform-tools\adb.exe install -r build\app\outputs\flutter-apk\app-debug.apk
```

## Frontend Tests and Checks

Run from `frontend/`:

```powershell
D:\Tools\flutter\bin\flutter.bat analyze
D:\Tools\flutter\bin\flutter.bat test
```

If Flutter is on PATH:

```powershell
flutter analyze
flutter test
```

## Full Local Smoke Test

1. Start the backend from `backend/`.
2. Confirm `http://127.0.0.1:8000/health` responds.
3. Start Flutter web or Android from `frontend/`.
4. Register or log in with Supabase Auth.
5. Select a court.
6. Open a session.
7. Join lobby/check in.
8. Confirm the Play flow advances through the prototype match states.

## Current App Behavior Notes

- Login and registration use Supabase Auth.
- Backend validates the Supabase JWT on protected API calls.
- Court selection, session listing, and event check-in are wired to backend APIs.
- Upcoming match, active match, match result, waiting verification, and return to
  queue are currently frontend workflow states until backend matchmaking and
  verification services are completed.

## Troubleshooting

If Flutter web cannot reach the API:

- Confirm the backend is running on port `8000`.
- Use `BACKEND_BASE_URL=http://localhost:8000/api/v1`.

If Android emulator cannot reach the API:

- Use `BACKEND_BASE_URL=http://10.0.2.2:8000/api/v1`.
- Confirm the backend is listening on the host machine.

If authentication fails:

- Confirm `SUPABASE_URL` is correct.
- Confirm `SUPABASE_PUBLISHABLE_KEY` is passed to Flutter.
- Confirm the backend `.env` has `SUPABASE_ANON_KEY`.

If migrations fail:

- Confirm `DATABASE_URL` points to the correct Supabase PostgreSQL database.
- Confirm the database user has migration permissions.

If tests fail after a dependency update:

- Reinstall dependencies in the relevant folder.
- Run backend tests from `backend/`.
- Run Flutter tests from `frontend/`.
