# Vyral — Flutter Client

Flutter mobile and web client for the Vyral social media app. Targets Android, iOS, and Chrome (web).

## Run

```bash
flutter pub get

# Web (Chrome)
flutter run -d chrome

# Android emulator
flutter run -d <emulator-id>
```

Start the backend API first (`../backend`, `npm run start:dev`).

### API base URL

The base URL is resolved at compile time via platform-specific config files:

| Target | Base URL | File |
|---|---|---|
| Chrome / Windows | `http://localhost:3000` | `lib/config/api_config_web.dart` |
| Android emulator | `http://10.0.2.2:3000` | `lib/config/api_config_io.dart` |
| Production | Deployed Vercel URL | Set via `api_config*.dart` |

## Architecture

```text
lib/
├── config/         API base URL resolution (platform-specific)
├── models/         Data models (FeedPost, SavedCollectionModel, UserSettings, …)
├── screens/        Full-page UI (21 screens)
├── services/       HTTP/API layer (ApiClient, AuthService, PostsApiService, …)
├── theme/          Material light/dark themes, typography (Inter + Playfair Display)
├── utils/          Helpers (error messages, media URL builders, file I/O)
├── widgets/        Reusable components (PostCard, navigation, inputs, …)
└── main.dart       App entry point, route table, RouteObserver
```

## Screens

| Screen | Route | Description |
|---|---|---|
| WelcomeScreen | `/` | Animated landing with sign-in/sign-up CTAs |
| LoginScreen | `/login` | Email + password login |
| SignupScreen | `/signup` | Registration form |
| ForgotPasswordScreen | `/forgot-password` | Password reset request |
| HomeFeedScreen | `/home` | Tabbed feed (For You / Following / Trending) |
| ExploreScreen | `/explore` | Masonry browse with search and category filters |
| SearchScreen | `/search` | Search users and posts |
| CreatePostScreen | `/create` | Compose post with image upload |
| PostDetailScreen | `/post/:id` | Full post view with comments |
| ProfileScreen | `/profile` | Own profile |
| UserProfileScreen | `/user/:id` | Public user profile |
| SavedScreen | `/saved` | Saved collections |
| CollectionDetailScreen | — | Posts inside a saved collection |
| EditProfileScreen | — | Edit name, bio, avatar, website |
| SettingsScreen | `/settings` | App and account settings |
| PasswordSecurityScreen | — | Security settings hub |
| ChangePasswordScreen | — | Change password form |
| FeedPreferencesScreen | — | Feed preferences |
| MutedWordsScreen | — | Manage muted words |
| BlockedAccountsScreen | — | Manage blocked users |
| LinkedAccountsScreen | — | Linked social accounts |

All screens except auth routes are wrapped in `AuthGuard`, which redirects to `/login` when no session is active.

## Services

| Service | Responsibility |
|---|---|
| `ApiClient` | Base HTTP client — attaches `Authorization` header, parses responses, surfaces structured errors |
| `AuthService` | Session management (login, logout, register, Google sign-in, token refresh); exposes `ChangeNotifier` for UI updates |
| `PostsApiService` | Feed, explore, like, comment, save, create, delete endpoints |
| `UsersApiService` | Profile, follow, unblock, settings, collections endpoints |
| `SettingsApiService` | User notification and app preference endpoints |
| `SettingsPreferences` | Local `SharedPreferences` for theme and client-side settings |
| `MediaPickerService` | Image and video selection (`image_picker` / `file_selector`) |
| `PostCreationService` | Upload + create-post flow helpers |
| `GoogleSignInHelper` | Google OAuth token retrieval |

## Key Widgets

| Widget | Description |
|---|---|
| `PostCard` | Full post display — media, caption, like/comment/save actions |
| `PostCommentsSheet` | Bottom sheet with paginated comments |
| `SaveCollectionSheet` | Collection picker bottom sheet |
| `VyralBottomNav` | Persistent bottom navigation bar |
| `VyralScaffold` | Common page wrapper (app bar, bottom nav) |
| `VyralInputField` | Styled form input with validation display |
| `VyralAnimations` | Heart-burst like animation, page transitions |
| `VyralResponsiveBody` | Constrains content width on tablet/desktop |
| `AuthGuard` | Route-level authentication check |
| `PickedImagePreview` | Platform-aware image preview (web/iOS/Android) |

## Theme

- Light and dark Material 3 themes defined in `lib/theme/vyral_theme.dart`
- Typography: **Inter** (body, UI) and **Playfair Display** (display/headings)
- Theme toggled at runtime via `ThemeScope` provider; preference persisted with `SharedPreferences`
- Accent color configurable per user via settings (`accentColor` in `UserSettings`)

## Dependencies

| Package | Use |
|---|---|
| `http` | REST API calls |
| `cached_network_image` | Image caching |
| `image_picker` | Camera/gallery image selection |
| `file_selector` | File picking on desktop/web |
| `flutter_staggered_grid_view` | Masonry grid layout in Explore |
| `shared_preferences` | Local settings persistence |
| `google_sign_in` | Google OAuth |
| `url_launcher` | Open external links |
