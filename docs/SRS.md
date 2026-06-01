# Software Requirements Specification
## Vyral — Social Media Application

| Field | Value |
|---|---|
| Version | 2.0 |
| Date | June 2026 |
| Institution | Arab Academy for Science, Technology & Maritime Transport |
| Project Type | Academic graduation project |
| Concept | Pinterest × Twitter — visual post sharing with a social follow graph |

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Overall Description](#2-overall-description)
3. [System Architecture](#3-system-architecture)
4. [Functional Requirements](#4-functional-requirements)
5. [Non-Functional Requirements](#5-non-functional-requirements)
6. [Data Models](#6-data-models)
7. [API Specification](#7-api-specification)
8. [Constraints and Assumptions](#8-constraints-and-assumptions)

---

## 1. Introduction

### 1.1 Purpose

This document specifies the software requirements for **Vyral**, a social media mobile application. It is intended for use by developers, academic supervisors, and project evaluators. It defines functional behavior, system architecture, data models, API contracts, and quality attributes for the implemented and deployed system.

### 1.2 Scope

Vyral merges the visual, grid-based content discovery of Pinterest with the text-and-image post feed of Twitter. Users publish posts (images, carousels, videos, text), interact through likes and comments, build a social graph through follows, and organise saved content into collections. The system comprises a Flutter mobile/web client, a NestJS REST API, a PostgreSQL database hosted on Supabase, and Supabase Storage for media files.

### 1.3 Definitions and Acronyms

| Term | Definition |
|---|---|
| SRS | Software Requirements Specification |
| API | Application Programming Interface |
| REST | Representational State Transfer |
| JWT | JSON Web Token |
| RLS | Row-Level Security (Supabase/PostgreSQL feature) |
| DTO | Data Transfer Object |
| ORM | Object-Relational Mapper |
| UUID | Universally Unique Identifier |

### 1.4 References

- NestJS documentation: https://nestjs.com
- Flutter documentation: https://flutter.dev
- Supabase documentation: https://supabase.com/docs
- TypeORM documentation: https://typeorm.io

---

## 2. Overall Description

### 2.1 Product Perspective

Vyral is a standalone social media application inspired by Pinterest (visual discovery, grid layout, saved collections) and Twitter/X (text and image posts, social follow graph, feed tabs). It does not integrate with or depend on any third-party social platform's content. It exposes its own REST API consumed exclusively by the Flutter client. Both the backend and the Flutter web build are deployed to Vercel; mobile builds run natively on Android and iOS.

### 2.2 User Classes

| Class | Description |
|---|---|
| **Guest** | Unauthenticated visitor. Can access only authentication screens. |
| **Registered User** | Authenticated account holder. Full access to all features. |
| **Creator** | Reserved role for future feature gating; no additional capabilities in the current version. |
| **Admin** | Reserved role for future moderation interfaces; no additional capabilities in the current version. |

### 2.3 Operating Environment

- **Mobile:** Android (API 34+), iOS
- **Web:** Modern evergreen browsers (Chrome primary target)
- **Backend:** Node.js 20 serverless runtime on Vercel
- **Database:** PostgreSQL 15 via Supabase managed cloud (eu-west-1)
- **Storage:** Supabase Storage (S3-compatible, public bucket)

### 2.4 Design Constraints

- The backend must be stateless (serverless-compatible); no in-memory session state.
- Authentication is entirely delegated to Supabase Auth; the backend only validates JWTs.
- All media is stored in Supabase Storage; the backend never stores binary data locally.
- The Flutter client must function on both mobile (Android/iOS) and web (Chrome) from a single codebase.

---

## 3. System Architecture

### 3.1 High-Level Overview

```
┌────────────────────────────────────┐
│         Flutter Client             │
│  (Android / iOS / Chrome)          │
│                                    │
│  Screens → Services → ApiClient    │
└────────────────┬───────────────────┘
                 │ HTTPS / REST
                 ▼
┌────────────────────────────────────┐
│          NestJS REST API           │
│  (Vercel Serverless, Node.js 20)   │
│                                    │
│  Controllers → Services → TypeORM  │
│  AuthGuard (JWT validation)        │
└────────┬───────────────────────────┘
         │                │
         ▼                ▼
  PostgreSQL DB     Supabase Storage
  (Supabase)        (media bucket)
         │
         ▼
  Supabase Auth
  (JWT issuance)
```

### 3.2 Backend Module Structure

```
src/
├── auth/           Authentication (register, login, OAuth, password management)
├── posts/          Post CRUD, feed, likes, comments, saves, pins
├── users/          Profiles, settings, collections, blocks, search
├── follows/        Follow / unfollow relationship management
├── explore/        Discovery feed with search and category filters
├── upload/         Media file upload to Supabase Storage
├── supabase/       SupabaseService (admin and anon clients)
└── common/
    ├── decorators/ @CurrentUser — injects authenticated user from JWT
    ├── filters/    DetailedExceptionFilter — structured error envelopes
    ├── guards/     AuthGuard — JWT Bearer token validation
    ├── mappers/    PostMapper, SettingsMapper
    ├── pipes/      ValidationExceptionFactory
    └── utils/      timeAgo helper
```

### 3.3 Frontend Module Structure

```
lib/
├── config/         Platform-specific API base URL (web vs. mobile)
├── models/         Dart data classes (FeedPost, SavedCollectionModel, …)
├── screens/        21 full-page screens
├── services/       HTTP service layer (ApiClient, AuthService, …)
├── theme/          Material 3 themes, Inter/Playfair typography
├── utils/          Error message formatters, media URL builders, file I/O
├── widgets/        Reusable UI components (PostCard, navigation, …)
└── main.dart       App bootstrap, named route table, RouteObserver
```

---

## 4. Functional Requirements

### 4.1 Authentication

#### FR-AUTH-01: User Registration
The system shall allow new users to register with a unique email address, a unique username (3–20 characters), full name, and a password (minimum 8 characters). On success the system returns an access token and refresh token.

#### FR-AUTH-02: Email/Password Login
The system shall authenticate registered users with their email and password, returning a JWT access token and refresh token.

#### FR-AUTH-03: Google Sign-In
The system shall accept a Google ID token from the Flutter Google Sign-In flow, verify it with Supabase Auth, and return or create a matching user account.

#### FR-AUTH-04: Token Refresh
The system shall issue a new access token when presented with a valid refresh token.

#### FR-AUTH-05: Logout
The system shall invalidate the authenticated user's active session on logout.

#### FR-AUTH-06: Forgot Password
The system shall send a password reset email to a registered address when requested.

#### FR-AUTH-07: Reset Password
The system shall accept a reset token from the emailed link and update the user's password.

#### FR-AUTH-08: Change Password
Authenticated users shall be able to change their password by providing the new password.

#### FR-AUTH-09: Route Protection
All non-auth endpoints shall require a valid Bearer JWT. Requests with missing or expired tokens receive `401 Unauthorized`.

---

### 4.2 Posts

#### FR-POST-01: Create Post
Authenticated users shall create posts of type IMAGE, CAROUSEL, VIDEO, or TEXT with an optional caption (max 280 characters), optional media URLs, hashtags, and location.

#### FR-POST-02: Home Feed
The system shall serve a paginated home feed with three selectable tabs:
- **For You** — algorithm-curated posts
- **Following** — posts from followed users only
- **Trending** — high-engagement public posts

Default page size is 20 posts.

#### FR-POST-03: Post Detail
Any authenticated user shall retrieve a single post by its UUID.

#### FR-POST-04: Edit Post
Post owners shall update the caption, hashtags, and location of their own posts.

#### FR-POST-05: Delete Post
Post owners shall delete their posts; deletion cascades to comments, likes, and saves.

#### FR-POST-06: Pin / Unpin Post
Post owners shall pin posts to the top of their profile grid. Pinned posts carry a `pinnedAt` timestamp. Unpinning clears it.

#### FR-POST-07: Like / Unlike
Authenticated users shall like or unlike any post. The post's `likesCount` updates accordingly. Duplicate likes are rejected.

#### FR-POST-08: Save / Unsave Post
Authenticated users shall save posts to a named collection or a default collection. Unsaving removes the record.

#### FR-POST-09: Comments
Authenticated users shall post comments on any post (max 500 characters) and retrieve paginated comment lists.

---

### 4.3 Explore

#### FR-EXP-01: Browse Feed
Authenticated users shall browse a paginated masonry grid of public posts without specifying a query.

#### FR-EXP-02: Search Posts
Users shall search posts by keyword (`q` parameter) with full-text matching against captions and hashtags.

#### FR-EXP-03: Category Filter
Users shall filter explore results by a content category (e.g., `fashion`, `travel`).

---

### 4.4 User Profiles

#### FR-USR-01: Own Profile
Authenticated users shall retrieve their own profile including follower count, following count, post count, and current settings.

#### FR-USR-02: Edit Profile
Users shall update their full name, bio, avatar URL, website URL, and pronouns.

#### FR-USR-03: Public Profile
Any authenticated user shall view another user's public profile. Private profiles show limited information until a follow is accepted.

#### FR-USR-04: User Posts Grid
Paginated posts for any user, ordered by most recent (pinned posts appear first). Default page size: 12.

#### FR-USR-05: Pinned Posts Grid
Paginated list of a user's pinned posts.

#### FR-USR-06: Liked Posts
Own liked posts are always accessible. Another user's liked posts are accessible only when their `showLikesPublicly` setting is enabled.

#### FR-USR-07: User Search
Full-text search for users by username or full name via the `q` query parameter.

#### FR-USR-08: Delete Account
Users shall permanently delete their own account. All associated content (posts, comments, follows, saves) is cascade-deleted.

---

### 4.5 Follows

#### FR-FOL-01: Follow User
Following a public-profile user immediately creates an ACCEPTED follow relationship. Following a private-profile user creates a PENDING request.

#### FR-FOL-02: Unfollow User
Users shall unfollow any user they currently follow, removing the relationship regardless of its status.

---

### 4.6 Saved Collections

#### FR-SAV-01: List Collections
Users shall retrieve a list of their named saved collections including post count per collection.

#### FR-SAV-02: Create Collection
Users shall create a named collection to organise saved posts.

#### FR-SAV-03: Collection Posts
Users shall retrieve paginated posts within a specific collection.

#### FR-SAV-04: Default Save
When saving without specifying a collection ID, the post is saved to the user's default ("All saved") collection.

---

### 4.7 Media Upload

#### FR-UPL-01: File Upload
Authenticated users shall upload an image or video file (multipart/form-data, field name `file`). The system stores the file in the `media` Supabase Storage bucket and returns a public URL. Maximum file size: 15 MB.

---

### 4.8 User Settings

#### FR-SET-01: Get Settings
Users shall retrieve their full settings record (notification preferences, app preferences, privacy).

#### FR-SET-02: Update Settings
Users shall update any subset of the following settings:

| Setting | Type | Default | Description |
|---|---|---|---|
| `showLikesPublicly` | boolean | true | Whether liked posts are visible to others |
| `notifLikes` | boolean | true | Notify on post likes |
| `notifComments` | boolean | true | Notify on comments |
| `notifFollowers` | boolean | true | Notify on new followers |
| `notifTrending` | boolean | false | Notify when a post is trending |
| `dataSaver` | boolean | false | Reduce image quality to save bandwidth |
| `hapticsEnabled` | boolean | true | Enable haptic feedback |
| `exploreGridCompact` | boolean | false | Compact explore grid density |
| `accentColor` | string | `rose` | UI accent colour key |
| `defaultFeedTab` | string | `for_you` | Default home feed tab on open |
| `mutedWords` | string[] | [] | Words to filter from the feed |

---

### 4.9 Blocking

#### FR-BLK-01: Block User
Users shall block another user, preventing future interactions. Blocking also removes any existing follow relationship between the two users. Duplicate blocks are rejected.

#### FR-BLK-02: Unblock User
Users shall unblock a previously blocked user.

#### FR-BLK-03: Blocked List
Users shall retrieve a paginated list of their blocked accounts.

---

## 5. Non-Functional Requirements

### 5.1 Performance

| Requirement | Target |
|---|---|
| API response time (feed endpoints) | < 1 500 ms at p95 under normal load |
| API response time (auth endpoints) | < 800 ms at p95 |
| File upload (15 MB) | < 30 seconds (Vercel function max duration) |
| Flutter cold start (web) | < 4 seconds on broadband |
| Image caching | Cached network images served from local cache on repeat views |

### 5.2 Security

- All API communication over HTTPS.
- JWTs signed by Supabase Auth; the backend validates signature and expiry on every protected request via `AuthGuard`.
- The Supabase service role key is used only server-side and never exposed to the client.
- Passwords are never stored by the backend; authentication is fully delegated to Supabase Auth.
- All DTO inputs are validated and whitelisted via `ValidationPipe` (unknown properties are stripped).
- User-uploaded media is stored in a public Supabase Storage bucket; no server-side execution of uploaded content occurs.
- SQL injection is mitigated by TypeORM's parameterised queries; no raw SQL in application code.

### 5.3 Reliability

- The backend is stateless and deployed as serverless functions; Vercel handles restarts on failure.
- Database connection pooling via Supabase's built-in PgBouncer pooler.
- Cascade deletes ensure referential integrity is maintained across all entity relationships on user or post deletion.

### 5.4 Usability

- Full light and dark theme support with user-controlled toggle persisted across sessions.
- Pull-to-refresh on all feed and list screens.
- `VyralResponsiveBody` constrains content width on tablet and desktop viewports.
- Accessible font sizing via Flutter's Material 3 theme scale.
- Haptic feedback on interactions, toggle-able via settings.

### 5.5 Maintainability

- Backend follows NestJS modular architecture; each feature domain is an isolated module with its own controller, service, module, and DTOs.
- TypeORM entities define the schema; migrations manage schema evolution.
- Global `DetailedExceptionFilter` provides consistent error envelopes across all endpoints.
- Flutter services are singleton classes; business logic is separated from widget code.
- Dart analysis enforces standard `flutter_lints` rules.

### 5.6 Portability

- The Flutter codebase compiles to Android, iOS, and web from a single source tree.
- Platform differences (file I/O, API base URL) are abstracted behind conditional imports and config files.
- The NestJS backend targets the Vercel serverless runtime but runs identically with `npm run start:dev` locally.

---

## 6. Data Models

### 6.1 Entity Relationship Summary

```
User ──< Post ──< Comment
     ──< Follow (follower / following)
     ──< PostLike
     ──< SavedPost >── SavedCollection
     ──1 UserSettings
     ──< UserBlock
```

### 6.2 Entity Definitions

#### User

| Column | Type | Constraints |
|---|---|---|
| id | UUID | PK, auto-generated |
| username | varchar | UNIQUE, NOT NULL |
| email | varchar | UNIQUE, NOT NULL |
| fullName | varchar | NOT NULL |
| bio | text | nullable |
| avatarUrl | varchar | nullable |
| websiteUrl | varchar | nullable |
| pronouns | varchar | nullable |
| isPrivate | boolean | DEFAULT false |
| isVerified | boolean | DEFAULT false |
| role | enum(USER, CREATOR, ADMIN) | DEFAULT USER |
| isSuspended | boolean | DEFAULT false |
| createdAt | timestamptz | auto |
| updatedAt | timestamptz | auto |

#### Post

| Column | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| authorId | UUID | FK → users(id) CASCADE |
| caption | text | nullable, max 280 characters |
| mediaUrls | varchar[] | DEFAULT [] |
| type | enum(IMAGE, CAROUSEL, VIDEO, TEXT) | NOT NULL |
| hashtags | varchar[] | DEFAULT [] |
| location | varchar | nullable |
| likesCount | int | DEFAULT 0 |
| commentsCount | int | DEFAULT 0 |
| savesCount | int | DEFAULT 0 |
| pinnedAt | timestamptz | nullable — set when pinned to profile |
| createdAt | timestamptz | auto |
| updatedAt | timestamptz | auto |

#### Comment

| Column | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| authorId | UUID | FK → users(id) CASCADE |
| postId | UUID | FK → posts(id) CASCADE, nullable |
| text | text | NOT NULL, max 500 characters |
| likesCount | int | DEFAULT 0 |
| createdAt | timestamptz | auto |

#### Follow

| Column | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| followerId | UUID | FK → users(id) CASCADE |
| followingId | UUID | FK → users(id) CASCADE |
| status | enum(PENDING, ACCEPTED) | DEFAULT ACCEPTED |
| createdAt | timestamptz | auto |
| — | UNIQUE(followerId, followingId) | prevents duplicate follows |

#### PostLike

| Column | Type | Constraints |
|---|---|---|
| userId | UUID | PK, FK → users(id) CASCADE |
| postId | UUID | PK, FK → posts(id) CASCADE |
| createdAt | timestamptz | auto |

#### SavedPost

| Column | Type | Constraints |
|---|---|---|
| userId | UUID | PK, FK → users(id) CASCADE |
| postId | UUID | PK, FK → posts(id) CASCADE |
| collectionId | UUID | FK → saved_collections(id) SET NULL, nullable |
| savedAt | timestamptz | auto |

#### SavedCollection

| Column | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| userId | UUID | FK → users(id) CASCADE |
| name | varchar | NOT NULL |
| createdAt | timestamptz | auto |

#### UserSettings

| Column | Type | Constraints |
|---|---|---|
| userId | UUID | PK (1:1 with User), FK → users(id) CASCADE |
| showLikesPublicly | boolean | DEFAULT true |
| notifLikes | boolean | DEFAULT true |
| notifComments | boolean | DEFAULT true |
| notifFollowers | boolean | DEFAULT true |
| notifTrending | boolean | DEFAULT false |
| dataSaver | boolean | DEFAULT false |
| hapticsEnabled | boolean | DEFAULT true |
| exploreGridCompact | boolean | DEFAULT false |
| accentColor | varchar | DEFAULT 'rose' |
| defaultFeedTab | varchar | DEFAULT 'for_you' |
| mutedWords | varchar[] | DEFAULT [] |

#### UserBlock

| Column | Type | Constraints |
|---|---|---|
| id | UUID | PK |
| blockerId | UUID | FK → users(id) CASCADE |
| blockedId | UUID | FK → users(id) CASCADE |
| createdAt | timestamptz | auto |
| — | UNIQUE(blockerId, blockedId) | prevents duplicate blocks |

---

## 7. API Specification

### 7.1 Base URL

| Environment | URL |
|---|---|
| Local development | `http://localhost:3000` |
| Android emulator | `http://10.0.2.2:3000` |
| Production (Vercel) | `https://vyral-backend.vercel.app` |

### 7.2 Authentication

All protected endpoints require:
```
Authorization: Bearer <supabase_access_token>
```

The backend validates the JWT signature using the Supabase JWKS endpoint. Expired or invalid tokens return `401 Unauthorized`.

### 7.3 Error Envelope

All error responses follow a consistent structure:

```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "details": [
    { "field": "username", "messages": ["username must be at least 3 characters"] }
  ],
  "path": "/auth/register",
  "method": "POST",
  "timestamp": "2026-06-01T10:00:00.000Z",
  "requestId": "uuid-v4"
}
```

The `x-request-id` response header duplicates `requestId` for log correlation.

| HTTP Status | When Used |
|---|---|
| 400 | Validation failure or invalid input |
| 401 | Missing or expired token |
| 403 | Authenticated but not authorised (e.g., editing another user's post) |
| 404 | Resource not found |
| 409 | Duplicate constraint violation |
| 413 | File upload exceeds 15 MB |
| 500 | Unexpected server error |

### 7.4 Endpoint Summary

#### Auth — `/auth`

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | — | Create account |
| POST | `/auth/login` | — | Email/password login |
| POST | `/auth/google` | — | Google ID token login |
| POST | `/auth/logout` | Yes | Invalidate session |
| POST | `/auth/refresh` | — | Refresh access token |
| POST | `/auth/forgot-password` | — | Send reset email |
| POST | `/auth/reset-password` | — | Reset password with token |
| POST | `/auth/change-password` | Yes | Change password |

#### Posts — `/posts`

| Method | Path | Description |
|---|---|---|
| GET | `/posts/feed` | Tabbed feed. Query: `tab` (`for_you`\|`following`\|`trending`), `page`, `limit` |
| POST | `/posts` | Create post |
| GET | `/posts/:id` | Get single post |
| PATCH | `/posts/:id` | Edit post (owner) |
| DELETE | `/posts/:id` | Delete post (owner) |
| POST | `/posts/:id/pin` | Pin post (owner) |
| DELETE | `/posts/:id/pin` | Unpin post (owner) |
| POST | `/posts/:id/like` | Like post |
| DELETE | `/posts/:id/like` | Unlike post |
| POST | `/posts/:id/save` | Save post. Query: `collectionId` (optional) |
| DELETE | `/posts/:id/save` | Unsave post |
| GET | `/posts/:id/comments` | List comments. Query: `page`, `limit` |
| POST | `/posts/:id/comments` | Add comment |

#### Explore — `/explore`

| Method | Path | Description |
|---|---|---|
| GET | `/explore/posts` | Browse/search. Query: `q`, `category`, `page`, `limit` |

#### Users — `/users`

| Method | Path | Description |
|---|---|---|
| GET | `/users/me` | Own profile with stats |
| PATCH | `/users/me` | Update profile |
| DELETE | `/users/me` | Delete account |
| GET | `/users/me/settings` | Get settings |
| PATCH | `/users/me/settings` | Update settings |
| GET | `/users/me/blocks` | List blocked users |
| POST | `/users/me/blocks/:userId` | Block user |
| DELETE | `/users/me/blocks/:userId` | Unblock user |
| GET | `/users/search?q=` | Search users |
| GET | `/users/me/posts` | Own posts |
| GET | `/users/me/pins` | Own pinned posts |
| GET | `/users/me/liked` | Own liked posts |
| GET | `/users/me/saved` | Saved posts (default collection) |
| GET | `/users/me/saved/collections` | List collections |
| POST | `/users/me/saved/collections` | Create collection |
| GET | `/users/me/saved/collections/:id/posts` | Posts in collection |
| GET | `/users/:id` | Public profile |
| GET | `/users/:id/posts` | User's posts |
| GET | `/users/:id/pins` | User's pinned posts |
| GET | `/users/:id/liked` | User's liked posts (respects `showLikesPublicly`) |
| POST | `/users/:id/follow` | Follow user |
| DELETE | `/users/:id/follow` | Unfollow user |

#### Upload — `/upload`

| Method | Path | Description |
|---|---|---|
| POST | `/upload` | Upload image/video (multipart, field `file`, max 15 MB). Returns `{ url }` |

### 7.5 Pagination

Paginated endpoints accept `page` (1-based, default 1) and `limit` query parameters. Responses include a `meta` object:

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 142,
    "hasNextPage": true
  }
}
```

### 7.6 Swagger

Interactive API documentation is available at `GET /docs` when the server is running.

---

## 8. Constraints and Assumptions

### 8.1 Technical Constraints

- Vercel serverless functions have a maximum execution duration of 30 seconds; file upload operations must complete within this limit.
- Supabase free-tier limits: 500 MB database storage, 2 GB bandwidth per month — scoped for academic demonstration load.
- The `media` Supabase Storage bucket is public; uploaded files are accessible to anyone with the URL. Per-file access control is not implemented.
- Flutter web builds require a single-page application rewrite rule (`/* → /index.html`) configured in `frontend/vercel.json`.

### 8.2 Validation Rules

| Field | Rule |
|---|---|
| username | 3–20 characters |
| password | minimum 8 characters |
| post caption | max 280 characters |
| comment text | max 500 characters |
| upload file size | max 15 MB |

### 8.3 Assumptions

- Each user account corresponds to exactly one Supabase Auth identity.
- Users are responsible for the legality of content they upload.
- The system is deployed in a low-concurrency academic context; horizontal scaling and rate limiting are out of scope for this version.
- Private-profile follow requests are stored as PENDING; acceptance/rejection UI is not implemented in this version — the follow status remains PENDING until manually resolved in the database.
