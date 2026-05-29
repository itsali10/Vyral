import 'dotenv/config';
import { AppDataSource } from '../src/data-source';
import { Comment } from '../src/entities/comment.entity';

async function main() {
  await AppDataSource.initialize();
  const repo = AppDataSource.getRepository(Comment);
  const postId = process.argv[2];
  if (!postId) {
    console.error('Usage: npx ts-node scripts/test-get-comments.ts <postId>');
    process.exit(1);
  }

  const findResult = await repo.findAndCount({
    where: { postId },
    relations: { author: true },
  });
  console.log('findAndCount:', findResult[0].length, 'items');

  const qbResult = await repo
    .createQueryBuilder('c')
    .leftJoinAndSelect('c.author', 'author')
    .where('c.postId = :postId', { postId })
    .getMany();
  console.log('queryBuilder:', qbResult.length, 'items');
  for (const c of qbResult) {
    console.log(`  ${c.author?.username}: ${c.text}`);
  }

  await AppDataSource.destroy();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
