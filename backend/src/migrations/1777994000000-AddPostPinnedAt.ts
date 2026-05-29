import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddPostPinnedAt1777994000000 implements MigrationInterface {
  name = 'AddPostPinnedAt1777994000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "posts" ADD COLUMN IF NOT EXISTS "pinnedAt" TIMESTAMPTZ`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "posts" DROP COLUMN IF EXISTS "pinnedAt"`);
  }
}
