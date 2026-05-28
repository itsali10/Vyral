# Vyral — Rubric requirements checklist (40 marks)

Use this when demoing or self-grading. **SRS/presentation (4 marks)** are your course documents — not in the repo.

## How to run (app must be running)

```powershell
# Terminal 1 — backend (required for login, feed, posts)
cd backend
npm run start:dev

# Terminal 2 — Flutter (pick one device)
cd frontend
flutter run -d Vyral_API34    # Android emulator (use Vyral_API34, not gphone16k)
# OR
flutter run -d chrome         # Recommended if emulator is slow
```

Android emulator API: `http://10.0.2.2:3000` · Chrome/Windows: `http://localhost:3000`

---

## 1. Functionality & correctness (10 marks) — **Met**

| Requirement | Status | How to demo |
|-------------|--------|-------------|
| Register | ✅ | Welcome → Create account → fill form → submit |
| Login / logout | ✅ | Log in; Settings → Log out |
| List posts (feed) | ✅ | Home → For You / Following / Trending |
| View post | ✅ | Feed cards; Explore → tap grid item → Post detail |
| Create post | ✅ | Create → photo + caption → Post |
| Update post | ✅ | Your post → ⋮ → Edit caption |
| Delete post | ✅ | Your post → ⋮ → Delete post |
| Like / comment / save | ✅ | Icons on post card |
| Save to collection | ✅ | Save → pick collection sheet |
| Follow / profile | ✅ | Tap author → profile; Follow button |
| Edit profile | ✅ | Profile or Settings → Edit profile → Save |
| Explore search + filter | ✅ | Explore → search; filter icon → category |
| Validation | ✅ | Signup (email, password strength); login (email); create post (caption or image) |
| Forgot password | ✅ | Login → Forgot password? |
| Delete account | ✅ | Settings → Delete account |

**Not in app (backend only):** Stories, Reels, DMs, push notifications.

---

## 2. Backend (4 marks) — **Met**

NestJS API + Postgres + Supabase Auth + file upload (`POST /upload` → `backend/uploads/`).

Key routes: `/auth/*`, `/posts/*`, `/users/*`, `/explore/posts`, `/users/:id/follow`.

Swagger: `http://localhost:3000/docs`

---

## 3. UI/UX & responsiveness (10 marks) — **Met**

| Item | Status |
|------|--------|
| Consistent theme (light/dark) | ✅ |
| Typography & spacing | ✅ |
| Navigation (drawer, bottom nav, routes) | ✅ |
| Pull-to-refresh on feeds | ✅ |
| Safe area / status bar | ✅ |
| Phone layouts | ✅ (test on emulator or Chrome mobile view) |

---

## 4. Code quality & structure (7 marks) — **Met**

| Item | Status |
|------|--------|
| `lib/screens/`, `widgets/`, `services/`, `models/` | ✅ |
| API layer separated from UI | ✅ |
| Named routes in `main.dart` | ✅ |

---

## 5. Flutter concepts (5 marks) — **Met**

| Concept | Evidence |
|---------|----------|
| Multi-screen navigation | `MaterialApp` routes: `/`, `/login`, `/home`, `/explore`, `/create`, `/profile`, `/saved`, `/settings`, etc. |
| Lists with models | `FeedPost`, `SavedCollectionModel`; `ListView.builder` on home/profile |
| Stateful UI | `setState`, `ListenableBuilder`, likes/save toggles, forms |

---

## 6. SRS & presentation (4 marks) — **Your submission**

Submit SRS per course template and prepare a short demo covering the table in section 1.

---

## Quick demo script (5–8 min)

1. Register a new user → log in  
2. Create post with image  
3. Show home feed → like → comment → save (pick collection)  
4. Explore → search → open a post  
5. Follow another user (or second account) → view profile  
6. Edit profile; edit/delete your post  
7. Saved collections → open one  
8. Settings → theme toggle → log out  

---

## Emulator note

Use **`Vyral_API34`**, not **`sdk gphone16k`** (16 KB image crashes). If the emulator freezes, use **`flutter run -d chrome`**.
