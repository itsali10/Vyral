import 'dotenv/config';
import { AppDataSource } from '../src/data-source';
import { ensureSettingsTablesExist } from '../src/database/ensure-settings-tables';

async function main() {
  await AppDataSource.initialize();
  await ensureSettingsTablesExist(AppDataSource);
  console.log('user_settings and user_blocks tables are ready.');
  await AppDataSource.destroy();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
