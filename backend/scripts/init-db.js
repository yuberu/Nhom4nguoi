// Chạy schema.sql rồi seed.sql lên database trong DATABASE_URL.
// Dùng:  npm run db:init      (XÓA toàn bộ bảng cũ rồi tạo lại)
const fs = require('fs');
const path = require('path');
const { pool } = require('../src/db');

async function main() {
  for (const tep of ['schema.sql', 'seed.sql']) {
    const sql = fs.readFileSync(path.join(__dirname, '..', tep), 'utf8');
    await pool.query(sql);
    console.log(`Đã chạy ${tep}`);
  }
}

main()
  .catch((err) => { console.error('Lỗi:', err.message); process.exitCode = 1; })
  .finally(() => pool.end());
