require('dotenv').config({ quiet: true });
const { Pool, types } = require('pg');

// NUMERIC (tiền) trả về dạng số thay vì chuỗi.
types.setTypeParser(1700, (v) => parseFloat(v));

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

// Luôn truyền giá trị qua tham số $1, $2... không nối chuỗi vào câu SQL.
const query = (text, params) => pool.query(text, params);

// Chạy nhiều câu lệnh trong 1 giao dịch: hoặc thành công hết, hoặc hoàn tác hết.
async function giaoDich(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const ketQua = await fn(client);
    await client.query('COMMIT');
    return ketQua;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { pool, query, giaoDich };
