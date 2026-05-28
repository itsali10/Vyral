import { DataSource } from 'typeorm';

/** Creates settings/block tables if missing (safe when migration was skipped or wrong DB). */
export async function ensureSettingsTablesExist(
  dataSource: DataSource,
): Promise<void> {
  await dataSource.query(`
    CREATE TABLE IF NOT EXISTS "user_settings" (
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

  await dataSource.query(`
    CREATE TABLE IF NOT EXISTS "user_blocks" (
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

  await dataSource.query(`
    CREATE INDEX IF NOT EXISTS "IDX_user_blocks_blocker" ON "user_blocks" ("blockerId")
  `);
}
