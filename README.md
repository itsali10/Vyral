# Vyral

Social feed app built for a Flutter course project: **Flutter client** + **NestJS API** + **PostgreSQL** (via Supabase Auth).

## Rubric alignment (40 marks)

| Category | Marks | Where to verify |
|----------|-------|-----------------|
| Functionality & correctness | 10 | End-to-end flows below; validation on signup, login, posts, comments |
| Backend | 4 | [`backend/`](backend/) — REST API, Swagger, DTO validation |
| UI/UX & responsiveness | 10 | Themed screens, navigation, pull-to-refresh, `VyralResponsiveBody` on wide layouts |
| Code quality & structure | 7 | `frontend/lib/screens`, `widgets`, `services`, `models` |
| Flutter concepts | 5 | Named routes, `ListView.builder` + `FeedPost`, `StatefulWidget` / `setState` |
| SRS & presentation | 4 | [`docs/SRS.md`](docs/SRS.md), [`docs/PRESENTATION_OUTLINE.md`](docs/PRESENTATION_OUTLINE.md) |

See also [`RUBRIC_CHECKLIST.md`](RUBRIC_CHECKLIST.md) for a demo script.

## Quick start

```powershell
# Terminal 1 — API (required)
cd backend
npm install
npm run start:dev

# Terminal 2 — Flutter
cd frontend
flutter pub get
flutter run -d chrome
# Android emulator: flutter run -d Vyral_API34  (API base: http://10.0.2.2:3000)
```

- API: http://localhost:3000  
- Swagger: http://localhost:3000/docs  

Configure Supabase/DB env in `backend/.env` (see `backend/README.md`).

## Core features (demo order)

1. Register → log in  
2. Create post (caption and/or image)  
3. Home feed — like, comment, save to collection  
4. Explore — search, filter, open post detail  
5. Profile — follow user, edit profile, edit/delete own posts  
6. Saved collections  
7. Settings — theme, log out, delete account  

## Project layout

```
Vyral/
├── backend/          NestJS API
├── frontend/         Flutter app
├── docs/             SRS + presentation outline
└── RUBRIC_CHECKLIST.md
```
