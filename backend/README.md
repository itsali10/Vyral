# Vyral API

NestJS REST backend for the Vyral social media app. Handles authentication, posts, feeds, reels, stories, user profiles, follows, saved collections, and media uploads.

## Stack

- **NestJS 11** + **TypeScript** + **TypeORM**
- **PostgreSQL** via Supabase (connection pooling on `aws-0-eu-west-1`)
- **Supabase Auth** — JWT tokens validated by `AuthGuard`
- **Supabase Storage** — public `media` bucket for images and videos
- **Swagger** auto-docs at `/docs`
- **Vercel** serverless deployment

## Setup

```bash
npm install
cp .env.example .env   # fill in your credentials
npm run start:dev       # http://localhost:3000
```

### Environment variables

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string (Supabase pooler URL) |
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous (public) key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key (bypasses RLS) |
| `SUPABASE_STORAGE_BUCKET` | Storage bucket name (default: `media`) |
| `PORT` | Server port (default: `3000`) |
| `API_PUBLIC_URL` | Public base URL (used for storage paths in production) |

Run `scripts/setup-storage.sql` in the Supabase SQL Editor once to create the `media` bucket with the correct public policy.

## API Endpoints

All protected routes require `Authorization: Bearer <access_token>`.

### Auth — `/auth`

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | — | Create a new account |
| POST | `/auth/login` | — | Login with email + password |
| POST | `/auth/google` | — | Sign in with Google ID token |
| POST | `/auth/logout` | Yes | Invalidate session |
| POST | `/auth/refresh` | — | Exchange refresh token for new access token |
| POST | `/auth/forgot-password` | — | Send password reset email |
| POST | `/auth/reset-password` | — | Reset password using emailed token |
| POST | `/auth/change-password` | Yes | Change password while authenticated |

### Posts — `/posts`

| Method | Path | Description |
|---|---|---|
| GET | `/posts/feed` | Tabbed home feed. Query: `tab` (`for_you`\|`following`\|`trending`), `page`, `limit` (default 20) |
| POST | `/posts` | Create a post (IMAGE, CAROUSEL, VIDEO, or TEXT) |
| GET | `/posts/:id` | Get a single post |
| PATCH | `/posts/:id` | Update post (owner only) |
| DELETE | `/posts/:id` | Delete post (owner only) |
| POST | `/posts/:id/pin` | Pin post to top of profile (owner only) |
| DELETE | `/posts/:id/pin` | Unpin post from profile (owner only) |
| POST | `/posts/:id/like` | Like a post |
| DELETE | `/posts/:id/like` | Unlike a post |
| POST | `/posts/:id/save` | Save to collection. Query: `collectionId` (optional) |
| DELETE | `/posts/:id/save` | Unsave a post |
| GET | `/posts/:id/comments` | List comments. Query: `page`, `limit` (default 20) |
| POST | `/posts/:id/comments` | Add a comment |

### Explore — `/explore`

| Method | Path | Description |
|---|---|---|
| GET | `/explore/posts` | Masonry browse/search. Query: `q` (search), `category`, `page`, `limit` (default 20) |

### Users — `/users`

| Method | Path | Description |
|---|---|---|
| GET | `/users/me` | Own profile with follower/following counts |
| PATCH | `/users/me` | Update own profile |
| DELETE | `/users/me` | Delete own account |
| GET | `/users/me/settings` | Get notification and app preferences |
| PATCH | `/users/me/settings` | Update preferences |
| GET | `/users/me/blocks` | List blocked users |
| POST | `/users/me/blocks/:userId` | Block a user |
| DELETE | `/users/me/blocks/:userId` | Unblock a user |
| GET | `/users/search` | Search users by username/name. Query: `q` (required) |
| GET | `/users/me/posts` | Own posts grid |
| GET | `/users/me/pins` | Own pinned posts grid |
| GET | `/users/me/liked` | Own liked posts |
| GET | `/users/me/saved` | Saved posts (default collection) |
| GET | `/users/me/saved/collections` | List saved collections |
| POST | `/users/me/saved/collections` | Create a collection |
| GET | `/users/me/saved/collections/:id/posts` | Posts in a collection |
| GET | `/users/:id` | Public profile of any user |
| GET | `/users/:id/posts` | A user's posts |
| GET | `/users/:id/pins` | A user's pinned posts |
| GET | `/users/:id/liked` | A user's liked posts (respects `showLikesPublicly` setting) |
### Follows — `/users`

| Method | Path | Description |
|---|---|---|
| POST | `/users/:id/follow` | Follow a user (PENDING if private, ACCEPTED if public) |
| DELETE | `/users/:id/follow` | Unfollow a user |

### Upload — `/upload`

| Method | Path | Description |
|---|---|---|
| POST | `/upload` | Upload image or video. Multipart field: `file`. Max size: 15 MB. Returns `{ url }` |

## Validation

Global `ValidationPipe` (whitelist, transform). Field-level error details in every 400 response:

```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "details": [
    { "field": "email", "messages": ["email must be an email"] }
  ],
  "path": "/auth/register",
  "method": "POST",
  "timestamp": "2026-05-01T12:00:00.000Z",
  "requestId": "4d0f0a21-8d56-4270-a590-8f823aeb89a6"
}
```

The `x-request-id` response header matches `requestId` for debugging. Notable constraints:

| Field | Rule |
|---|---|
| username | 3–20 characters |
| password | minimum 8 characters |
| post caption | max 280 characters |
| comment | max 500 characters |

## Deploying to Vercel

Deploy the `backend/` folder as a standalone Vercel project. Set all environment variables listed above in the Vercel dashboard — Vercel does not read your local `.env`. The `vercel.json` config routes all paths through `api/index.ts` and sets a 30-second max function duration.

## Database

```bash
npm run migration:run    # apply pending migrations
npm run migration:generate -- --name <name>   # generate a new migration
npm run db:seed          # seed test data
```

## Tests

```bash
npm run test
npm run test:e2e
npm run test:cov
```
