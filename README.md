# Vyral

Social feed app built for a Flutter course project: **Flutter client** + **NestJS API** + **PostgreSQL** (via Supabase Auth).

## Quick Start

```powershell
# Terminal 1 - API (required)
cd backend
npm install
npm run start:dev

# Terminal 2 - Flutter
cd frontend
flutter pub get
flutter run -d chrome
# Android emulator: flutter run -d Vyral_API34  (API base: http://10.0.2.2:3000)
```

- API: http://localhost:3000
- Swagger: http://localhost:3000/docs

Configure Supabase/DB env in `backend/.env` (see `backend/README.md`).

## Core Features

1. Register and log in
2. Create post with caption and/or image
3. Home feed with like, comment, and save to collection
4. Explore with search, filters, and post detail
5. Profile with follow, edit profile, and edit/delete own posts
6. Saved collections
7. Settings with theme, log out, and delete account

## Project Layout

```text
Vyral/
├── backend/          NestJS API
├── frontend/         Flutter app
└── docs/             SRS + presentation outline
```
