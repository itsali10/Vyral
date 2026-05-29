import 'dotenv/config';
import { AppDataSource } from '../src/data-source';
import { Comment } from '../src/entities/comment.entity';
import { Post } from '../src/entities/post.entity';

async function main() {
  await AppDataSource.initialize();
  const commentRepo = AppDataSource.getRepository(Comment);
  const postRepo = AppDataSource.getRepository(Post);

  const commentTotal = await commentRepo.count();
  const postTotal = await postRepo.count();
  const withPost = await commentRepo.count({
    where: {},
  });

  console.log(`Posts: ${postTotal}`);
  console.log(`Comments (all): ${commentTotal}`);

  const sample = await commentRepo.find({
    take: 5,
    relations: { author: true },
    order: { createdAt: 'DESC' },
  });
  for (const c of sample) {
    console.log(
      `- postId=${c.postId ?? 'NULL'} author=${c.author?.username ?? c.authorId} text=${c.text?.slice(0, 40)}`,
    );
  }

  const postsWithCounts = await postRepo
    .createQueryBuilder('p')
    .leftJoin('p.comments', 'c')
    .select('p.id', 'id')
    .addSelect('p.caption', 'caption')
    .addSelect('p.commentsCount', 'storedCount')
    .addSelect('COUNT(c.id)', 'actualCount')
    .groupBy('p.id')
    .addGroupBy('p.caption')
    .addGroupBy('p.commentsCount')
    .having('COUNT(c.id) > 0 OR p.commentsCount > 0')
    .orderBy('actualCount', 'DESC')
    .limit(10)
    .getRawMany();

  console.log('\nPosts with comments (stored vs actual):');
  for (const row of postsWithCounts) {
    console.log(
      `  ${String(row.caption ?? '').slice(0, 40)} stored=${row.storedCount} actual=${row.actualCount} id=${row.id}`,
    );
  }

  await AppDataSource.destroy();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
