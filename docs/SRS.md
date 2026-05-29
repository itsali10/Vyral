# Software Requirements Specification (SRS)
## Vyral — Social Feed Application

**Version:** 1.0  
**Date:** May 2026  
**Course project:** Flutter mobile development  

> **Note for submission:** Copy or adapt this document into your instructor’s SRS template (Word/PDF). Fill in **team member names and roles** in Section 1.3 before submitting.

---

## 1. Introduction

### 1.1 Purpose
This SRS describes functional and non-functional requirements for **Vyral**, a social-style mobile/web client where users register, publish posts, browse feeds, interact with content, and manage profiles. It aligns with the implemented Flutter app and NestJS backend.

### 1.2 Scope
**In scope:** User authentication, post CRUD, home feed tabs, explore/search, likes, comments, saves/collections, follow, profile edit, settings (theme, privacy, account deletion).  
**Out of scope (future):** Stories, reels, direct messages, push notifications (backend entities may exist but are not exposed in the client).

### 1.3 Team roles (fill in before submit)
| Member | Role | Responsibilities |
|--------|------|------------------|
| _Name_ | _e.g. Flutter lead_ | UI screens, navigation, state |
| _Name_ | _e.g. Backend lead_ | API, database, auth |
| _Name_ | _e.g. QA / docs_ | Testing, SRS, demo script |

### 1.4 Definitions
- **Post:** User-created content with optional image and caption.  
- **Feed:** Chronological or ranked list of posts (For You, Following, Trending).  
- **Collection:** Named group for saved posts.

---

## 2. Overall description

### 2.1 Product perspective
Vyral is a **client–server** system:

- **Flutter** frontend (`frontend/`) — presentation and validation.  
- **NestJS** backend (`backend/`) — business logic, persistence, Supabase JWT auth.  
- **PostgreSQL** — relational data (users, posts, likes, comments, follows, saves).

### 2.2 User classes
- **Guest:** Welcome, login, signup, forgot password.  
- **Registered user:** All authenticated features.

### 2.3 Operating environment
- Android emulator/device, iOS (optional), Chrome/desktop for development.  
- API host: `localhost:3000` (desktop) or `10.0.2.2:3000` (Android emulator).

### 2.4 Constraints
- Requires running backend for auth and data (not offline-first).  
- Image upload via backend `/upload` before post creation.

---

## 3. Functional requirements

### 3.1 Authentication (FR-AUTH)
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-AUTH-1 | User can register with full name, username (3–20, alphanumeric/._), email, password (≥8). | Must |
| FR-AUTH-2 | User can log in with email and password. | Must |
| FR-AUTH-3 | User can log out from settings/drawer. | Must |
| FR-AUTH-4 | User can request password reset (forgot password flow). | Should |
| FR-AUTH-5 | User can delete own account from settings. | Should |
| FR-AUTH-6 | Optional: Continue with Google. | Could |

**Validation:** Client-side email regex and password rules; server `RegisterDto` / `LoginDto` validation.

### 3.2 Posts (FR-POST)
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-POST-1 | User can create a post with caption and/or image (at least one required). | Must |
| FR-POST-2 | Caption length ≤ 280 characters (client + server). | Must |
| FR-POST-3 | User can view posts in home feed (list). | Must |
| FR-POST-4 | User can view single post (detail screen). | Must |
| FR-POST-5 | Owner can edit post caption. | Must |
| FR-POST-6 | Owner can delete post (with confirmation). | Must |
| FR-POST-7 | User can like/unlike and save/unsave posts. | Must |
| FR-POST-8 | User can add comments (non-empty, ≤500 chars). | Must |
| FR-POST-9 | Owner can pin/unpin post on profile. | Should |

### 3.3 Feed & explore (FR-FEED)
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-FEED-1 | Home shows tabs: For You, Following, Trending. | Must |
| FR-FEED-2 | Pull-to-refresh reloads feed data. | Must |
| FR-FEED-3 | Explore shows searchable grid; filter by category. | Must |
| FR-FEED-4 | Tapping explore item opens post detail. | Must |

### 3.4 Social & profile (FR-SOC)
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-SOC-1 | User can view other users’ profiles. | Must |
| FR-SOC-2 | User can follow/unfollow. | Must |
| FR-SOC-3 | User can edit own profile (name, username, bio). | Must |
| FR-SOC-4 | User can save posts to collections and view saved screen. | Must |

### 3.5 Settings (FR-SET)
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-SET-1 | Toggle light/dark theme. | Should |
| FR-SET-2 | Feed preferences (default tab). | Could |
| FR-SET-3 | Blocked accounts, muted words (where implemented). | Could |

---

## 4. Non-functional requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-1 | Usability | Consistent typography, spacing, and navigation (drawer + bottom nav). |
| NFR-2 | Responsiveness | Layout readable on phone; content centered on wide screens (`VyralResponsiveBody`). |
| NFR-3 | Performance | Feed loads with loading indicator; errors show retry. |
| NFR-4 | Security | API calls use bearer token; protected routes redirect guests to welcome. |
| NFR-5 | Maintainability | Separation: screens / widgets / services / models. |
| NFR-6 | Documentation | API documented in Swagger (`/docs`). |

---

## 5. External interface requirements

### 5.1 User interfaces
- Material Design screens: Welcome, Login, Signup, Home, Explore, Create Post, Profile, Saved, Settings, Post Detail, Edit Profile.

### 5.2 Software interfaces
- REST JSON API (NestJS), base URL configurable per platform.  
- Supabase Auth for registration/login tokens.

### 5.3 Hardware interfaces
- Camera/gallery (image picker) for post images on mobile; file picker on web.

---

## 6. System features traceability (implementation)

| Requirement | Frontend | Backend |
|-------------|----------|---------|
| FR-AUTH-* | `auth_service.dart`, login/signup screens | `auth.controller.ts`, Supabase |
| FR-POST-* | `create_post_screen.dart`, `post_card.dart`, `posts_api_service.dart` | `posts.controller.ts`, `posts.service.ts` |
| FR-FEED-* | `home_feed_screen.dart`, `explore_screen.dart` | `GET /posts/feed`, `GET /explore/posts` |
| FR-SOC-* | `profile_screen.dart`, `users_api_service.dart` | `users.controller.ts`, `follows` |
| FR-SET-* | `settings_screen.dart` | `users` settings endpoints |

---

## 7. Appendices

### 7.1 Demo resources
See [`PRESENTATION_OUTLINE.md`](PRESENTATION_OUTLINE.md).

### 7.2 Revision history
| Version | Date | Changes |
|---------|------|---------|
| 1.0 | May 2026 | Initial SRS aligned with implemented Vyral app |
