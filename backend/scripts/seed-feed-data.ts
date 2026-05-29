import 'dotenv/config';
import { randomUUID } from 'crypto';
import { AppDataSource } from '../src/data-source';
import { User } from '../src/entities/user.entity';
import { Post } from '../src/entities/post.entity';
import { PostLike } from '../src/entities/post-like.entity';
import { Comment } from '../src/entities/comment.entity';
import { UserSettings } from '../src/entities/user-settings.entity';
import { PostType } from '../src/entities/enums';
import { ensureSettingsTablesExist } from '../src/database/ensure-settings-tables';

const SEED_EMAIL_DOMAIN = '@vyral.seed';

type SeedAuthor = {
  username: string;
  fullName: string;
  bio: string;
  email: string;
};

type SeedPost = {
  authorUsername: string;
  caption: string;
  type: PostType;
  mediaUrls?: string[];
  hashtags?: string[];
  /** 0–5: capped to other demo accounts that can like (max 5 seed authors). */
  likesCount: number;
  /** Display count only; small thread sizes for a tiny network. */
  commentsCount: number;
  hoursAgo: number;
};

/** With 6 seed users, at most 5 distinct accounts can like someone else's post. */
const MAX_SEED_LIKES = 5;

const SEED_COMMENT_TEXTS = [
  'This is lovely!',
  'Great shot.',
  'Needed to see this today.',
  'So well said.',
  'Saving this for later.',
];

const AUTHORS: SeedAuthor[] = [
  {
    username: 'lena_creates',
    fullName: 'Lena Hart',
    bio: 'Soft aesthetics · weekend shoots · coffee first',
    email: `seed.lena${SEED_EMAIL_DOMAIN}`,
  },
  {
    username: 'marcus_frames',
    fullName: 'Marcus Cole',
    bio: 'Street frames & golden hour chasers',
    email: `seed.marcus${SEED_EMAIL_DOMAIN}`,
  },
  {
    username: 'priya_sketches',
    fullName: 'Priya Nair',
    bio: 'Illustrator · mood boards · tiny joys',
    email: `seed.priya${SEED_EMAIL_DOMAIN}`,
  },
  {
    username: 'noah_waves',
    fullName: 'Noah Ellis',
    bio: 'Coastal walks · film grain · slow living',
    email: `seed.noah${SEED_EMAIL_DOMAIN}`,
  },
  {
    username: 'zoe_palette',
    fullName: 'Zoe Marin',
    bio: 'Color studies · studio diaries · #design',
    email: `seed.zoe${SEED_EMAIL_DOMAIN}`,
  },
  {
    username: 'kai_urban',
    fullName: 'Kai Ortiz',
    bio: 'City nights · neon reflections · beats',
    email: `seed.kai${SEED_EMAIL_DOMAIN}`,
  },
];

const POSTS: SeedPost[] = [
  {
    authorUsername: 'lena_creates',
    caption: 'Sunday market finds — linen, ceramics, and too many candles.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-lena-1/900/700'],
    hashtags: ['lifestyle', 'slowliving'],
    likesCount: 3,
    commentsCount: 2,
    hoursAgo: 3,
  },
  {
    authorUsername: 'lena_creates',
    caption: 'Palette check for the next shoot. Rose dust + deep charcoal?',
    type: PostType.TEXT,
    likesCount: 1,
    commentsCount: 3,
    hoursAgo: 18,
  },
  {
    authorUsername: 'marcus_frames',
    caption: 'Rain on glass, shutter at 1/60. #street #mood',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-marcus-1/900/700'],
    hashtags: ['street', 'photography'],
    likesCount: 4,
    commentsCount: 2,
    hoursAgo: 5,
  },
  {
    authorUsername: 'marcus_frames',
    caption: 'Chasing alleys before the city wakes up.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-marcus-2/900/700'],
    likesCount: 2,
    commentsCount: 1,
    hoursAgo: 26,
  },
  {
    authorUsername: 'priya_sketches',
    caption: 'Warm-up doodles turned into a mini series.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-priya-1/900/700'],
    hashtags: ['art', 'sketch'],
    likesCount: 3,
    commentsCount: 1,
    hoursAgo: 8,
  },
  {
    authorUsername: 'priya_sketches',
    caption: 'Question for creators: analog or digital first?',
    type: PostType.TEXT,
    likesCount: 2,
    commentsCount: 3,
    hoursAgo: 40,
  },
  {
    authorUsername: 'noah_waves',
    caption: 'Tide line at dusk — no filter, just salt air.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-noah-1/900/700'],
    hashtags: ['coast', 'calm'],
    likesCount: 5,
    commentsCount: 2,
    hoursAgo: 2,
  },
  {
    authorUsername: 'noah_waves',
    caption: 'Playlist for long drives: soft indie + distant drums.',
    type: PostType.TEXT,
    likesCount: 1,
    commentsCount: 0,
    hoursAgo: 52,
  },
  {
    authorUsername: 'zoe_palette',
    caption: 'New gradient study — blush to ink blue.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-zoe-1/900/700'],
    hashtags: ['design', 'color'],
    likesCount: 3,
    commentsCount: 1,
    hoursAgo: 12,
  },
  {
    authorUsername: 'zoe_palette',
    caption: 'Studio desk reset. Less clutter, more focus.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-zoe-2/900/700'],
    likesCount: 2,
    commentsCount: 0,
    hoursAgo: 30,
  },
  {
    authorUsername: 'kai_urban',
    caption: 'Neon puddle reflections after midnight.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-kai-1/900/700'],
    hashtags: ['night', 'urban'],
    likesCount: 4,
    commentsCount: 2,
    hoursAgo: 6,
  },
  {
    authorUsername: 'kai_urban',
    caption: 'Open mic tonight — who is pulling up?',
    type: PostType.TEXT,
    likesCount: 2,
    commentsCount: 2,
    hoursAgo: 14,
  },
  {
    authorUsername: 'marcus_frames',
    caption: 'Testing a new 35mm lens in low light.',
    type: PostType.TEXT,
    likesCount: 0,
    commentsCount: 1,
    hoursAgo: 72,
  },
  {
    authorUsername: 'lena_creates',
    caption: 'Behind the scenes: styling flat lays with thrifted props.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-lena-2/900/700'],
    likesCount: 2,
    commentsCount: 1,
    hoursAgo: 36,
  },
  {
    authorUsername: 'priya_sketches',
    caption: 'Ink wash experiment — messy but honest.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-priya-2/900/700'],
    likesCount: 4,
    commentsCount: 1,
    hoursAgo: 4,
  },
  {
    authorUsername: 'zoe_palette',
    caption: 'Trending palettes this week: terracotta + sage.',
    type: PostType.TEXT,
    hashtags: ['trending', 'design'],
    likesCount: 5,
    commentsCount: 3,
    hoursAgo: 1,
  },
  {
    authorUsername: 'noah_waves',
    caption: 'Fog rolled in early — muted tones everywhere.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-noah-2/900/700'],
    likesCount: 3,
    commentsCount: 1,
    hoursAgo: 20,
  },
  {
    authorUsername: 'kai_urban',
    caption: 'Rooftop set — bass lines and city hum.',
    type: PostType.IMAGE,
    mediaUrls: ['https://picsum.photos/seed/vyral-kai-2/900/700'],
    likesCount: 3,
    commentsCount: 1,
    hoursAgo: 10,
  },
];

function hoursAgoDate(hours: number): Date {
  return new Date(Date.now() - hours * 60 * 60 * 1000);
}

function avatarFor(username: string): string {
  return `https://api.dicebear.com/7.x/avataaars/png?seed=${encodeURIComponent(username)}`;
}

function shuffleIds(ids: string[]): string[] {
  const copy = [...ids];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

async function main() {
  const force =
    process.argv.includes('--force') ||
    process.env.SEED_FORCE === '1' ||
    process.env.npm_config_force === 'true';

  if (!process.env.DATABASE_URL) {
    console.error('DATABASE_URL is missing. Set it in backend/.env');
    process.exit(1);
  }

  await AppDataSource.initialize();
  await ensureSettingsTablesExist(AppDataSource);

  const userRepo = AppDataSource.getRepository(User);
  const postRepo = AppDataSource.getRepository(Post);
  const likeRepo = AppDataSource.getRepository(PostLike);
  const commentRepo = AppDataSource.getRepository(Comment);
  const settingsRepo = AppDataSource.getRepository(UserSettings);

  const marker = await userRepo.findOne({
    where: { email: AUTHORS[0].email },
  });

  if (marker && !force) {
    console.log(
      'Feed seed already exists (seed.lena@vyral.seed). Use --force to replace.',
    );
    await AppDataSource.destroy();
    return;
  }

  if (marker && force) {
    const seedUsers = await userRepo
      .createQueryBuilder('u')
      .where('u.email LIKE :pattern', { pattern: `%${SEED_EMAIL_DOMAIN}` })
      .getMany();
    const seedIds = seedUsers.map((u) => u.id);
    if (seedIds.length > 0) {
      await likeRepo
        .createQueryBuilder()
        .delete()
        .from(PostLike)
        .where(
          `"postId" IN (SELECT id FROM posts WHERE "authorId" IN (:...ids))`,
          { ids: seedIds },
        )
        .execute();
      await postRepo
        .createQueryBuilder()
        .delete()
        .from(Post)
        .where('"authorId" IN (:...ids)', { ids: seedIds })
        .execute();
      await settingsRepo
        .createQueryBuilder()
        .delete()
        .from(UserSettings)
        .where('"userId" IN (:...ids)', { ids: seedIds })
        .execute();
      await userRepo.delete(seedIds);
    }
    console.log('Removed previous seed users and posts.');
  }

  const authorIdByUsername = new Map<string, string>();

  for (const author of AUTHORS) {
    const id = randomUUID();
    authorIdByUsername.set(author.username, id);
    await userRepo.save(
      userRepo.create({
        id,
        username: author.username,
        email: author.email,
        fullName: author.fullName,
        bio: author.bio,
        avatarUrl: avatarFor(author.username),
        isVerified: author.username === 'zoe_palette' || author.username === 'noah_waves',
      }),
    );
    await settingsRepo.save(settingsRepo.create({ userId: id }));
  }

  const authorIds = [...authorIdByUsername.values()];
  let postCount = 0;

  for (const seed of POSTS) {
    const authorId = authorIdByUsername.get(seed.authorUsername);
    if (!authorId) continue;

    const createdAt = hoursAgoDate(seed.hoursAgo);
    const likerPool = shuffleIds(authorIds.filter((id) => id !== authorId));
    const targetLikes = Math.min(
      Math.max(0, seed.likesCount),
      MAX_SEED_LIKES,
      likerPool.length,
    );
    const commentsCount = Math.min(Math.max(0, seed.commentsCount), 3);
    const savesCount = targetLikes > 0 ? (targetLikes >= 3 ? 1 : 0) : 0;

    const post = postRepo.create({
      id: randomUUID(),
      authorId,
      type: seed.type,
      caption: seed.caption,
      mediaUrls: seed.mediaUrls ?? [],
      hashtags: seed.hashtags ?? [],
      likesCount: targetLikes,
      commentsCount,
      savesCount,
      createdAt,
      updatedAt: createdAt,
    });
    await postRepo.save(post);
    postCount += 1;

    for (let i = 0; i < targetLikes; i += 1) {
      const likerId = likerPool[i];
      await likeRepo.save(likeRepo.create({ postId: post.id, userId: likerId }));
    }

    for (let i = 0; i < commentsCount; i += 1) {
      const commenterId = likerPool[i % likerPool.length];
      await commentRepo.save(
        commentRepo.create({
          postId: post.id,
          authorId: commenterId,
          text: SEED_COMMENT_TEXTS[(postCount + i) % SEED_COMMENT_TEXTS.length],
        }),
      );
    }
  }

  console.log(`Seeded ${AUTHORS.length} demo accounts and ${postCount} posts.`);
  console.log('These appear in For You (recent) and Trending (by likes).');
  console.log(`Demo users use emails ending in ${SEED_EMAIL_DOMAIN}`);
  console.log('Log in with your normal account to browse feeds.');

  await AppDataSource.destroy();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
