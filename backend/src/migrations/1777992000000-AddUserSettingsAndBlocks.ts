import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserSettingsAndBlocks1777992000000
  implements MigrationInterface
{
  name = 'AddUserSettingsAndBlocks1777992000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "user_settings" (
        "userId" uuid NOT NULL,
        "showLikesPublicly" boolean NOT NULL DEFAULT true,
        "notifLikes" boolean NOT NULL DEFAULT true,
        "notifComments" boolean NOT NULL DEFAULT true,
        "notifFollowers" boolean NOT NULL DEFAULT true,
        "notifTrending" boolean NOT NULL DEFAULT false,
        "dataSaver" boolean NOT NULL DEFAULT false,
        "hapticsEnabled" boolean NOT NULL DEFAULT true,
        "exploreGridCompact" boolean NOT NULL DEFAULT false,
        "accentColor" character varying NOT NULL DEFAULT 'rose',
        "defaultFeedTab" character varying NOT NULL DEFAULT 'for_you',
        "mutedWords" text array NOT NULL DEFAULT '{}',
        CONSTRAINT "PK_user_settings" PRIMARY KEY ("userId"),
        CONSTRAINT "FK_user_settings_user" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    await queryRunner.query(`
      CREATE TABLE "user_blocks" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "blockerId" uuid NOT NULL,
        "blockedId" uuid NOT NULL,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_user_blocks" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_user_blocks_pair" UNIQUE ("blockerId", "blockedId"),
        CONSTRAINT "FK_user_blocks_blocker" FOREIGN KEY ("blockerId") REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_user_blocks_blocked" FOREIGN KEY ("blockedId") REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_user_blocks_blocker" ON "user_blocks" ("blockerId")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "IDX_user_blocks_blocker"`);
    await queryRunner.query(`DROP TABLE "user_blocks"`);
    await queryRunner.query(`DROP TABLE "user_settings"`);
  }
}
