// app.js

const express = require('express');
const authRoutes = require('./routes/auth');
const categoryRoutes = require('./routes/category');
const userRoutes = require('./routes/user');
const app = express();
const PORT = process.env.PORT || 4000;
require('dotenv').config();
const fs = require('fs');
const path = require('path');

// Middleware để phân tích JSON
app.use(express.json());

// Kiểm tra và tạo thư mục uploads nếu chưa tồn tại
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log('Thư mục uploads đã được tạo.');
}

// Cấu hình để phục vụ tệp tĩnh
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Định nghĩa routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);        // Routes cho người dùng
app.use('/api/category', categoryRoutes); // Routes cho danh mục

// Bắt lỗi 404 (Đặt sau tất cả các routes)
app.use((req, res, next) => {
  res.status(404).json({ message: 'Route không tồn tại.' });
});

// Bắt lỗi chung
app.use((err, req, res, next) => {
  console.error('Lỗi chung: ', err.stack);
  res.status(500).json({ message: 'Đã xảy ra lỗi trên server.' });
});

// Kết nối cơ sở dữ liệu và khởi động server
const { sql, poolPromise } = require('./db');

poolPromise.then(() => {
  app.listen(PORT, () => {
    console.log(`Server chạy trên cổng ${PORT}`);
  });
}).catch(err => {
  console.error('Không thể khởi động server:', err);
});
