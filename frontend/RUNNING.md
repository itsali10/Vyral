# Running Vyral (Flutter + Backend API)

## 1. Start the backend

```powershell
cd backend
# Ensure .env has DATABASE_URL, SUPABASE_* keys, PORT=3000, API_PUBLIC_URL=http://localhost:3000
npm install
npm run migration:run
npm run start:dev
```

API: `http://localhost:3000`  
Swagger: `http://localhost:3000/docs`

## 2. Run the Flutter app

```powershell
cd frontend
flutter pub get
flutter run -d chrome
# or Windows desktop (native file picker from your laptop):
flutter run -d windows
```

**Upload photos from your laptop:** run Vyral on your PC (not the Android emulator):

```powershell
flutter run -d windows
# or
flutter run -d chrome
```

Create post → **Photo** opens a **Windows file picker** (your laptop files). Files upload via `POST /upload`.

On the **Android emulator**, gallery = emulator storage only. Copy images into the emulator first, or use `-d windows` / `-d chrome` above.

### Android emulator API URL

The app uses `http://10.0.2.2:3000` on Android (host machine). Override:

```powershell
flutter run -d <device> --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Windows/desktop uses `http://localhost:3000`.

## 3. Test the integration

1. **Sign up** — creates account via `POST /auth/register`, stores JWT locally.
2. **Log in** — `POST /auth/login`.
3. **Home** — loads `GET /posts/feed?tab=for_you|following|trending`.
4. **Create post** — uploads image via `POST /upload`, then `POST /posts`.
5. **Explore** — `GET /explore/posts?q=&category=`.
6. **Profile** — `GET /users/me`, posts, pins grid.
7. **Saved** — collections from `GET /users/me/saved/collections`.
8. **Settings → Log out** — `POST /auth/logout`.

## Auth note

The app uses the NestJS backend + Supabase Auth tokens.

## Emulator issues

### `DeadSystemException` / `Can't find service: package` / `Broken pipe`

The APK **built successfully**. Android **emulator system services crashed** while installing or launching — not a Dart compile error.

You are on **`sdk gphone16k x86 64`** (16 KB page-size image). That AVD is often unstable on Windows. Fix:

1. **Close the emulator** completely (Device Manager → Stop, or kill `qemu-system-*` in Task Manager).
2. **Cold boot** the AVD: Device Manager → ⋮ on the device → **Cold Boot Now**.
3. If it still fails: **delete** AVDs that use **16 KB** (`ps16k` in the system image path) and use the pre-created **`Vyral_API34`** AVD (Android 14, standard image), or create manually:
   - **Pixel 7a** device profile
   - System image: **API 34** → **Google Play Intel x86_64** (must **not** say “16 KB Page Size”)
   - RAM **4096 MB**
4. Launch:
   ```powershell
   flutter emulators --launch Vyral_API34
   flutter run -d Vyral_API34
   ```
4. Restart ADB:
   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```
5. Run again:
   ```powershell
   cd frontend
   flutter clean
   flutter pub get
   flutter run
   ```

### Faster alternative (no emulator)

```powershell
flutter run -d chrome
# or
flutter run -d windows
```

Backend must be on `http://localhost:3000` for Chrome/Windows; Android emulator uses `http://10.0.2.2:3000`.

### `System UI isn't responding` / `Skipped 800+ frames` / `Lost connection to device`

The app **installed and started** (`flutter was loaded normally`). The **emulator OS** froze under load (System UI ANR), then Flutter lost the connection.

**Do this:**

1. **Stop using `sdk gphone16k x86 64`** — create a **Pixel 6 + API 34/35** AVD (standard x86_64, not 16 KB).
2. **Enable Windows Developer Mode** (for Flutter plugin symlinks):
   ```powershell
   start ms-settings:developers
   ```
   Turn on **Developer Mode**, then `flutter pub get` again.
3. **Start the backend before the app** so session check does not hang:
   ```powershell
   cd backend
   npm run start:dev
   ```
4. On the emulator dialog: tap **Wait** once; if it appears again, **Close app**, cold boot the AVD, and `flutter run` again.

Startup was updated so the UI paints before the `/users/me` network call (reduces main-thread stalls on weak emulators).
