// routes/user.js

const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');
const authenticate = require('../middleware/authenticate');

// Lấy thông tin người dùng
router.get('/profile', authenticate, async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('UserID', sql.Int, req.user.userId)
      .query(`
        SELECT 
          u.UserID, 
          u.Username, 
          u.Email, 
          u.Phone, 
          u.FirstName, 
          u.LastName, 
          u.AvatarUrl,
          r.RoleName AS Role
        FROM Users u
        LEFT JOIN UserRoles ur ON u.UserID = ur.UserID
        LEFT JOIN Roles r ON ur.RoleID = r.RoleID
        WHERE u.UserID = @UserID
      `);

    if (result.recordset.length > 0) {
      res.status(200).json(result.recordset[0]);
    } else {
      res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }
  } catch (err) {
    console.error('Lỗi khi lấy thông tin người dùng:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

module.exports = router;
