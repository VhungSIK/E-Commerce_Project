// routes/auth.js

const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { sql, poolPromise } = require('../db');
const authenticate = require('../middleware/authenticate');
require('dotenv').config();

// Endpoint Đăng ký Người dùng
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;

  // Kiểm tra các trường bắt buộc
  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin.' });
  }

  try {
    const pool = await poolPromise;

    // Kiểm tra xem email đã tồn tại chưa
    const userResult = await pool.request()
      .input('Email', sql.NVarChar, email)
      .query('SELECT * FROM Users WHERE Email = @Email');

    if (userResult.recordset.length > 0) {
      return res.status(400).json({ message: 'Email đã được sử dụng.' });
    }

    // Hash mật khẩu
    const hashedPassword = await bcrypt.hash(password, 10);

    // Thêm người dùng vào cơ sở dữ liệu
    const insertUser = await pool.request()
      .input('Username', sql.NVarChar, username)
      .input('Email', sql.NVarChar, email)
      .input('PasswordHash', sql.NVarChar, hashedPassword)
      .query(`
        INSERT INTO Users (Username, Email, PasswordHash, IsActive)
        VALUES (@Username, @Email, @PasswordHash, 1);
        SELECT SCOPE_IDENTITY() AS UserID;
      `);

    const newUserId = insertUser.recordset[0].UserID;

    // Gán vai trò mặc định cho người dùng (ví dụ: 'user')
    const defaultRoleId = 1; // Đảm bảo RoleID cho 'user' là 1 trong bảng Roles
    await pool.request()
      .input('UserID', sql.Int, newUserId)
      .input('RoleID', sql.Int, defaultRoleId)
      .query(`
        INSERT INTO UserRoles (UserID, RoleID)
        VALUES (@UserID, @RoleID);
      `);

    // Tạo token JWT
    const token = jwt.sign(
      { userId: newUserId, email, role: 'user' },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.status(201).json({
      token,
      userId: newUserId,
      username,
      role: 'user'
    });
  } catch (err) {
    console.error('Lỗi khi đăng ký:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// Endpoint Đăng nhập Người dùng (Chỉ giữ lại một định nghĩa)
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
