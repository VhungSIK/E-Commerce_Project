const express = require('express');
const authRoutes = require('./routes/auth'); // Đảm bảo đường dẫn đúng
const categoryRoutes = require('./routes/category'); // Import route cho category
const app = express();
const PORT = process.env.PORT || 4000;
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const userRoutes = require('./routes/user');


app.use(express.json());
app.use('/api/user', userRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/category', categoryRoutes);
// Kiểm tra và tạo thư mục uploads nếu chưa tồn tại
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log('Thư mục uploads đã được tạo.');
}

// Đặt middleware express.json() ở đây, trước khi sử dụng các route
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Sử dụng các route đã định nghĩa trong routes/auth.js và category.js
app.use('/api', authRoutes);
app.use('/api/category', categoryRoutes); // Sử dụng route cho danh mục

// Bắt lỗi 404
app.use((req, res, next) => {
  res.status(404).json({ message: 'Route không tồn tại.' });
});

// Bắt lỗi chung
app.use((err, req, res, next) => {
  console.error('Lỗi chung: ', err.stack);
  res.status(500).json({ message: 'Đã xảy ra lỗi trên server.' });
});

// Thiết lập kết nối đến SQL Server một lần duy nhất
const { sql, poolPromise } = require('./db'); // Import từ db.js

// Khởi động server sau khi kết nối cơ sở dữ liệu thành công
poolPromise.then(() => {
  app.listen(PORT, () => {
    console.log(`Server chạy trên cổng ${PORT}`);
  });
}).catch(err => {
  console.error('Không thể khởi động server:', err);
});
