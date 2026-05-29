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

| Area    | Routes                                                                             |
| ------- | ---------------------------------------------------------------------------------- |
| Auth    | `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, password reset    |
| Posts   | `GET /posts/feed`, `POST /posts`, `GET/PATCH/DELETE /posts/:id`, like/save/comment |
| Explore | `GET /explore/posts?q=&category=`                                                  |
| Users   | `GET/PATCH /users/me`, `GET /users/:id`, follow/unfollow, collections, settings    |
| Upload  | `POST /upload` (multipart image → `uploads/`)                                      |

All protected routes use `Authorization: Bearer <access_token>`.

## Validation

Global `ValidationPipe` (whitelist, transform). DTOs use `class-validator`, e.g.:

- Register: email, username 3–20 chars, password min 8
- Post caption: max 280 characters
- Comments: max 500 characters

Validation errors return field-level details:

```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "details": [
    {
      "field": "email",
      "messages": ["email must be an email"]
    }
  ],
  "path": "/auth/register",
  "method": "POST",
  "timestamp": "2026-05-30T00:00:00.000Z",
  "requestId": "4d0f0a21-8d56-4270-a590-8f823aeb89a6"
}
```

All API errors use the same envelope. Expected HTTP errors keep their original
message, database conflicts are mapped to `409`, invalid references/IDs to
`400`, upload size errors to `413`, and unexpected failures to `500`. The
`x-request-id` response header matches the `requestId` body field for debugging.

## Database

Run migrations as configured in your environment (`npm run migration:run` or project scripts).

## Tests

```bash
npm run test
npm run test:e2e
```
