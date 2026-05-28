import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddSavedCollections1777991000000 implements MigrationInterface {
  name = 'AddSavedCollections1777991000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "saved_collections" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "userId" uuid NOT NULL,
        "name" character varying NOT NULL,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_saved_collections" PRIMARY KEY ("id"),
        CONSTRAINT "FK_saved_collections_user" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(`
      ALTER TABLE "saved_posts" ADD "collectionId" uuid
    `);
    await queryRunner.query(`
      ALTER TABLE "saved_posts"
      ADD CONSTRAINT "FK_saved_posts_collection"
      FOREIGN KEY ("collectionId") REFERENCES "saved_collections"("id") ON DELETE SET NULL
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "saved_posts" DROP CONSTRAINT "FK_saved_posts_collection"`,
    );
    await queryRunner.query(`ALTER TABLE "saved_posts" DROP COLUMN "collectionId"`);
    await queryRunner.query(`DROP TABLE "saved_collections"`);
  }
}
