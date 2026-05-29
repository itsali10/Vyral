# Vyral API (NestJS)

REST backend for the Vyral Flutter app: authentication, posts, feed, explore, users, follows, saved collections, and file uploads.

## Stack

- **NestJS** + **TypeORM** + **PostgreSQL**
- **Supabase Auth** (JWT validation via `AuthGuard`)
- **Swagger** at `/docs`
- Static uploads served at `/uploads/`

## Setup

```bash
npm install
cp .env.example .env   # if present; otherwise create .env
npm run start:dev
```

Server listens on **port 3000** (override with `PORT`).

## Main endpoints

| Area | Routes |
|------|--------|
| Auth | `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, password reset |
| Posts | `GET /posts/feed`, `POST /posts`, `GET/PATCH/DELETE /posts/:id`, like/save/comment |
| Explore | `GET /explore/posts?q=&category=` |
| Users | `GET/PATCH /users/me`, `GET /users/:id`, follow/unfollow, collections, settings |
| Upload | `POST /upload` (multipart image → `uploads/`) |

All protected routes use `Authorization: Bearer <access_token>`.

## Validation

Global `ValidationPipe` (whitelist, transform). DTOs use `class-validator`, e.g.:

- Register: email, username 3–20 chars, password min 8  
- Post caption: max 280 characters  
- Comments: max 500 characters  

## Database

Run migrations as configured in your environment (`npm run migration:run` or project scripts).

## Tests

```bash
npm run test
npm run test:e2e
```
