// fbwa_backend/middleware/authenticate.js

const jwt = require('jsonwebtoken');
require('dotenv').config();

const authenticate = (req, res, next) => {
  const authHeader = req.headers['authorization'];

  // Kiểm tra xem header Authorization có tồn tại không
  if (!authHeader) {
    return res.status(401).json({ message: 'Không tìm thấy token. Vui lòng đăng nhập.' });
  }

  // Token được gửi theo định dạng "Bearer <token>"
  const token = authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Không tìm thấy token. Vui lòng đăng nhập.' });
  }

  try {
    // Xác thực token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Thêm thông tin người dùng vào req
    next(); // Tiếp tục xử lý yêu cầu
  } catch (err) {
    return res.status(403).json({ message: 'Token không hợp lệ hoặc đã hết hạn.' });
  }
};

module.exports = authenticate;
