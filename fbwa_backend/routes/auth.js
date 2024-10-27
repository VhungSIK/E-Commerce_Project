// routes/auth.js

const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { sql, poolPromise } = require('../db');
const authenticate = require('../middleware/authenticate');
require('dotenv').config();

// Endpoint Đăng nhập Người dùng
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // Kiểm tra các trường bắt buộc
  if (!email || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập email và mật khẩu.' });
  }

  try {
    const pool = await poolPromise;

    // Lấy thông tin người dùng từ email
    const userResult = await pool.request()
      .input('Email', sql.NVarChar, email)
      .query('SELECT * FROM Users WHERE Email = @Email AND IsActive = 1');

    if (userResult.recordset.length === 0) {
      return res.status(400).json({ message: 'Email không tồn tại hoặc tài khoản đã bị vô hiệu hóa.' });
    }

    const user = userResult.recordset[0];

    // So sánh mật khẩu
    const isMatch = await bcrypt.compare(password, user.PasswordHash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Mật khẩu không chính xác.' });
    }

    // Lấy vai trò của người dùng
    const roleResult = await pool.request()
      .input('UserID', sql.Int, user.UserID)
      .query('SELECT RoleName FROM Roles r INNER JOIN UserRoles ur ON r.RoleID = ur.RoleID WHERE ur.UserID = @UserID');

    const role = roleResult.recordset.length > 0 ? roleResult.recordset[0].RoleName : 'user';

    // Tạo token JWT
    const token = jwt.sign(
      { userId: user.UserID, email: user.Email, role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    // Log token tại đây (chỉ nên làm trong môi trường phát triển)
    console.log(`User ID: ${user.UserID} đã đăng nhập thành công. Token: ${token}`);

    res.status(200).json({
      token,
      userId: user.UserID,
      username: user.Username,
      role
    });
  } catch (err) {
    console.error('Lỗi khi đăng nhập:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});


// Endpoint Đăng nhập Người dùng
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // Kiểm tra các trường bắt buộc
  if (!email || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập email và mật khẩu.' });
  }

  try {
    const pool = await poolPromise;

    // Lấy thông tin người dùng từ email
    const userResult = await pool.request()
      .input('Email', sql.NVarChar, email)
      .query('SELECT * FROM Users WHERE Email = @Email AND IsActive = 1');

    if (userResult.recordset.length === 0) {
      return res.status(400).json({ message: 'Email không tồn tại hoặc tài khoản đã bị vô hiệu hóa.' });
    }

    const user = userResult.recordset[0];

    // So sánh mật khẩu
    const isMatch = await bcrypt.compare(password, user.PasswordHash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Mật khẩu không chính xác.' });
    }

    // Lấy vai trò của người dùng
    const roleResult = await pool.request()
      .input('UserID', sql.Int, user.UserID)
      .query('SELECT RoleName FROM Roles r INNER JOIN UserRoles ur ON r.RoleID = ur.RoleID WHERE ur.UserID = @UserID');

    const role = roleResult.recordset.length > 0 ? roleResult.recordset[0].RoleName : 'user';

    // Tạo token JWT
    const token = jwt.sign(
      { userId: user.UserID, email: user.Email, role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.status(200).json({
      token,
      userId: user.UserID,
      username: user.Username,
      role
    });
  } catch (err) {
    console.error('Lỗi khi đăng nhập:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// Middleware bảo vệ trang admin
function checkAdmin(req, res, next) {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Bạn không có quyền truy cập.' });
  }
  next();
}

// Route được bảo vệ chỉ dành cho admin
router.get('/admin/protected', authenticate, checkAdmin, (req, res) => {
  res.status(200).json({ message: 'Chào mừng Admin!' });
});

module.exports = router;
