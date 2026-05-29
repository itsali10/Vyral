import 'dotenv/config';
import { AppDataSource } from '../src/data-source';
import { Comment } from '../src/entities/comment.entity';
import { Post } from '../src/entities/post.entity';
import { User } from '../src/entities/user.entity';

const COMMENT_TEXTS = [
  'This is lovely!',
  'Great shot.',
  'Needed to see this today.',
  'So well said.',
  'Saving this for later.',
  'Beautiful work.',
  'Love the vibe here.',
];

async function main() {
  await AppDataSource.initialize();
  const postRepo = AppDataSource.getRepository(Post);
  const commentRepo = AppDataSource.getRepository(Comment);
  const userRepo = AppDataSource.getRepository(User);

  const posts = await postRepo.find();
  const users = await userRepo.find();
  let created = 0;
  let synced = 0;

  for (const post of posts) {
    const actual = await commentRepo.count({ where: { postId: post.id } });
    const target = Math.max(0, post.commentsCount);
    const pool = users.filter((u) => u.id !== post.authorId);
    if (pool.length === 0) continue;

    let current = actual;
    while (current < target) {
      const author = pool[current % pool.length];
      await commentRepo.save(
        commentRepo.create({
          postId: post.id,
          authorId: author.id,
          text: COMMENT_TEXTS[(created + current) % COMMENT_TEXTS.length],
        }),
      );
      current += 1;
      created += 1;
    }

    const finalCount = await commentRepo.count({ where: { postId: post.id } });
    if (finalCount !== post.commentsCount) {
      await postRepo.update({ id: post.id }, { commentsCount: finalCount });
      synced += 1;
    }
  }

  // Posts with inflated count 0 but stray stored value
  for (const post of posts) {
    const finalCount = await commentRepo.count({ where: { postId: post.id } });
    if (post.commentsCount !== finalCount) {
      await postRepo.update({ id: post.id }, { commentsCount: finalCount });
      synced += 1;
    }
  }

  const total = await commentRepo.count();
  console.log(`Created ${created} missing comment(s).`);
  console.log(`Synced commentsCount on ${synced} post(s).`);
  console.log(`Total comments in database: ${total}`);

  await AppDataSource.destroy();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
