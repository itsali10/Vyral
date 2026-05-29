import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Ensures likes, saves, and comments are removed when a post is deleted.
 */
export class EnsurePostDeleteCascade1777993000000
  implements MigrationInterface
{
  name = 'EnsurePostDeleteCascade1777993000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const constraints = [
      {
        table: 'comments',
        column: 'postId',
        name: 'comments_postId_fkey',
        alts: ['FK_e44ddaaa6d058cb4092f83ad61f'],
      },
      {
        table: 'post_likes',
        column: 'postId',
        name: 'post_likes_postId_fkey',
        alts: ['FK_6999d13aca25e33515210abaf16'],
      },
      {
        table: 'saved_posts',
        column: 'postId',
        name: 'saved_posts_postId_fkey',
        alts: ['FK_4704fa96cd2b591592a8cfaee56'],
      },
    ];

    for (const { table, column, name, alts } of constraints) {
      await queryRunner.query(
        `ALTER TABLE "${table}" DROP CONSTRAINT IF EXISTS "${name}"`,
      );
      for (const alt of alts) {
        await queryRunner.query(
          `ALTER TABLE "${table}" DROP CONSTRAINT IF EXISTS "${alt}"`,
        );
      }
      await queryRunner.query(
        `ALTER TABLE "${table}" ADD CONSTRAINT "${name}" FOREIGN KEY ("${column}") REFERENCES "posts"("id") ON DELETE CASCADE ON UPDATE NO ACTION`,
      );
    }
  }

  public async down(): Promise<void> {
    // Non-destructive: DB keeps CASCADE behavior.
  }
}
