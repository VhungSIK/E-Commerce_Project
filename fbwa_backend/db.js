// fbwa_backend/db.js

const sql = require('mssql');
require('dotenv').config(); // Nạp biến môi trường từ .env

const dbConfig = {
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD || '031204',
  server: process.env.DB_SERVER || 'LAPTOP-PJ8L5TV2', // Đảm bảo đây là chuỗi hợp lệ
  database: process.env.DB_DATABASE || 'FBWA_DATABASE',
  options: {
    encrypt: false, // Đặt thành true nếu sử dụng SSL
    trustServerCertificate: true, // Thiết lập này cần thiết cho SQL Server
  },
};

// Kết nối một lần duy nhất và xuất pool
const poolPromise = new sql.ConnectionPool(dbConfig)
  .connect()
  .then(pool => {
    console.log('Kết nối cơ sở dữ liệu thành công');
    return pool;
  })
  .catch(err => {
    console.error('Kết nối cơ sở dữ liệu thất bại: ', err);
    process.exit(1); // Dừng server nếu kết nối thất bại
  });

module.exports = {
  sql,
  poolPromise,
};
