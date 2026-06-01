# Vyral

A social media mobile application built as an academic project at the Arab Academy for Science, Technology & Maritime Transport. Vyral lets users share posts, follow each other, explore content, and interact through likes, comments, and saved collections — with a full-featured Flutter client backed by a NestJS REST API.

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile client | Flutter (Dart) — Android, iOS, Web |
| Backend API | NestJS 11 + TypeScript |
| Database | PostgreSQL via Supabase |
| Auth | Supabase Auth (JWT) |
| Media storage | Supabase Storage |
| Deployment | Vercel (backend + Flutter web) |

## Features

- **Authentication** — Register, login, Google sign-in, forgot/reset password, change password
- **Home feed** — Tabbed feed (For You, Following, Trending) with infinite scroll, like, comment, and save
- **Posts** — Create image, carousel, video, or text posts; pin posts to profile; edit and delete
- **Explore** — Masonry grid browse with full-text search and category filters
- **Profiles** — Public and private profiles, follow/unfollow with pending-request support, posts and pins grids
- **Saved collections** — Organize saved posts into named collections
- **Settings** — Theme toggle (light/dark), notification preferences, muted words, blocked accounts, account deletion

## Quick Start

```powershell
# Terminal 1 — API
cd backend
npm install
# copy .env.example to .env and fill in Supabase credentials
npm run start:dev

# Terminal 2 — Flutter
cd frontend
flutter pub get
flutter run -d chrome
# Android emulator: flutter run -d <emulator-id>
```

- API: `http://localhost:3000`
- Swagger docs: `http://localhost:3000/docs`

See [backend/README.md](backend/README.md) for environment variables and deployment.  
See [frontend/README.md](frontend/README.md) for Flutter targets and architecture.

## Project Layout

```text
Vyral/
├── backend/        NestJS REST API (TypeScript)
├── frontend/       Flutter client (Dart)
└── docs/           SRS and project documentation
```
