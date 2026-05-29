# Vyral — Flutter client

## Run

```bash
flutter pub get
flutter run -d chrome
```

With the API on the same machine:

- **Chrome / Windows**: `http://localhost:3000` (see `lib/config/api_config*.dart`)
- **Android emulator**: `http://10.0.2.2:3000`

Start the backend first (`../backend`, `npm run start:dev`).

## Architecture

| Folder | Role |
|--------|------|
| `lib/screens/` | Full-page UI (feed, explore, auth, profile, settings) |
| `lib/widgets/` | Reusable UI (`PostCard`, navigation, inputs) |
| `lib/models/` | Data models (`FeedPost`, `SavedCollectionModel`) |
| `lib/services/` | HTTP/API (`ApiClient`, `AuthService`, `PostsApiService`) |
| `lib/theme/` | Colors, typography, light/dark themes |

## Flutter concepts

1. **Multi-screen navigation** — `MaterialApp` named routes in `lib/main.dart` (`/home`, `/explore`, `/create`, …).  
2. **Lists with models** — `FeedPost` lists rendered with `ListView.builder` on home and profile.  
3. **Stateful UI** — `StatefulWidget` + `setState` for feeds, likes, forms, and theme toggle.

## UI notes

- Light/dark theme via `ThemeScope` / Settings  
- Pull-to-refresh on feeds and explore  
- `VyralResponsiveBody` centers content on wide screens (tablet/desktop)
