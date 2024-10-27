const express = require('express');
const router = express.Router();
const multer = require('multer');
const { sql, poolPromise } = require('../db');
const path = require('path');

// Cấu hình multer để upload file
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Thư mục lưu trữ ảnh
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname)); // Đặt tên file
  }
});

const upload = multer({ storage: storage });

// API để tạo sản phẩm và upload ảnh
router.post('/createProduct', upload.single('image'), async (req, res) => {
  const { productName, description, price, sku, stockQuantity, categoryId } = req.body;

  // Kiểm tra input từ client
  if (!productName || !price || !sku || !stockQuantity || !categoryId) {
    return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin sản phẩm.' });
  }

  try {
    const pool = await poolPromise;
    const insertRequest = pool.request();

    // Kiểm tra nếu có ảnh thì lấy đường dẫn ảnh từ multer
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;

    // Thêm sản phẩm mới vào cơ sở dữ liệu
    await insertRequest
      .input('ProductName', sql.NVarChar, productName)
      .input('Description', sql.NVarChar, description)
      .input('Price', sql.Decimal(18, 2), price)
      .input('SKU', sql.NVarChar, sku)
      .input('StockQuantity', sql.Int, stockQuantity)
      .input('CategoryID', sql.Int, categoryId)
      .input('ImageURL', sql.NVarChar, imageUrl) // Lưu đường dẫn ảnh
      .query(`
        INSERT INTO Products (ProductName, Description, Price, SKU, StockQuantity, CategoryID, ImageURL, DateAdded, IsActive)
        VALUES (@ProductName, @Description, @Price, @SKU, @StockQuantity, @CategoryID, @ImageURL, GETDATE(), 1)
      `);

    res.status(201).json({ message: 'Sản phẩm đã được tạo thành công.' });
  } catch (err) {
    console.error('Lỗi khi tạo sản phẩm:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});
// API để xóa sản phẩm
router.delete('/deleteProduct/:productId', async (req, res) => {
  const { productId } = req.params;

  try {
    const pool = await poolPromise;
    const request = pool.request();
    await request.input('ProductID', sql.Int, productId)
      .query('DELETE FROM Products WHERE ProductID = @ProductID');
    
    res.status(200).json({ message: 'Sản phẩm đã được xóa thành công.' });
  } catch (err) {
    console.error('Lỗi khi xóa sản phẩm:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// API để cập nhật sản phẩm
router.put('/updateProduct/:productId', upload.single('image'), async (req, res) => {
  const { productId } = req.params;
  const { productName, description, price, sku, stockQuantity } = req.body;

  if (!productName || !price || !sku || !stockQuantity) {
    return res.status(400).json({ message: 'Vui lòng điền đầy đủ thông tin sản phẩm.' });
  }

  try {
    const pool = await poolPromise;
    const request = pool.request();

    // Kiểm tra nếu có ảnh thì lấy đường dẫn ảnh từ multer
    const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;

    // Thực hiện lệnh SQL để cập nhật sản phẩm
    const result = await request
      .input('ProductID', sql.Int, productId)
      .input('ProductName', sql.NVarChar, productName)
      .input('Description', sql.NVarChar, description)
      .input('Price', sql.Decimal(18, 2), price)
      .input('SKU', sql.NVarChar, sku)
      .input('StockQuantity', sql.Int, stockQuantity)
      .input('ImageURL', sql.NVarChar, imageUrl)
      .query(`
        UPDATE Products
        SET ProductName = @ProductName,
            Description = @Description,
            Price = @Price,
            SKU = @SKU,
            StockQuantity = @StockQuantity,
            ImageURL = COALESCE(@ImageURL, ImageURL) -- Chỉ cập nhật ImageURL nếu có ảnh mới
        WHERE ProductID = @ProductID
      `);

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: 'Sản phẩm đã được cập nhật thành công.' });
    } else {
      res.status(404).json({ message: 'Không tìm thấy sản phẩm để cập nhật.' });
    }
  } catch (err) {
    console.error('Lỗi khi cập nhật sản phẩm:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});
// API để lấy danh sách danh mục cha
router.get('/categories', async (req, res) => {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    const result = await request.query('SELECT * FROM Categories WHERE ParentCategoryID IS NULL');
    res.status(200).json(result.recordset);
  } catch (err) {
    console.error('Lỗi khi lấy danh mục cha:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// API để thêm danh mục cha
router.post('/addCategory', async (req, res) => {
  const { categoryName } = req.body;
  if (!categoryName) return res.status(400).json({ message: 'Tên danh mục không được bỏ trống.' });

  try {
    const pool = await poolPromise;
    const insertRequest = pool.request();
    await insertRequest.input('CategoryName', sql.NVarChar, categoryName)
      .query('INSERT INTO Categories (CategoryName, ParentCategoryID) VALUES (@CategoryName, NULL)');
    res.status(201).json({ message: 'Thêm danh mục thành công.' });
  } catch (err) {
    console.error('Lỗi thêm danh mục:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// API để lấy danh sách danh mục con dựa trên ParentCategoryID
router.get('/subCategories/:parentCategoryId', async (req, res) => {
  const { parentCategoryId } = req.params;

  try {
    const pool = await poolPromise;
    const request = pool.request();
    const result = await request
      .input('ParentCategoryID', sql.Int, parentCategoryId)
      .query('SELECT * FROM Categories WHERE ParentCategoryID = @ParentCategoryID');
    res.status(200).json(result.recordset);
  } catch (err) {
    console.error('Lỗi khi lấy danh sách danh mục con:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// API để thêm danh mục con
router.post('/addSubCategory', async (req, res) => {
  const { categoryName, parentCategoryId } = req.body;
  if (!categoryName || !parentCategoryId) return res.status(400).json({ message: 'Tên danh mục và ParentCategoryID không được bỏ trống.' });

  try {
    const pool = await poolPromise;
    const insertRequest = pool.request();
    await insertRequest
      .input('CategoryName', sql.NVarChar, categoryName)
      .input('ParentCategoryID', sql.Int, parentCategoryId)
      .query('INSERT INTO Categories (CategoryName, ParentCategoryID) VALUES (@CategoryName, @ParentCategoryID)');
    res.status(201).json({ message: 'Thêm danh mục con thành công.' });
  } catch (err) {
    console.error('Lỗi thêm danh mục con:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// API để lấy danh sách sản phẩm theo CategoryID
router.get('/products/:categoryId', async (req, res) => {
  const { categoryId } = req.params;

  try {
    const pool = await poolPromise;
    const request = pool.request();
    const result = await request
      .input('CategoryID', sql.Int, categoryId)
      .query('SELECT * FROM Products WHERE CategoryID = @CategoryID');
    res.status(200).json(result.recordset);
  } catch (err) {
    console.error('Lỗi khi lấy danh sách sản phẩm:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// API để lấy danh mục cha và danh mục con
router.post('/categoriesWithSubCategories', async (req, res) => {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    const result = await request.query(`
      SELECT 
        Categories.CategoryID, 
        Categories.CategoryName,
        SubCategories.CategoryID as SubCategoryID,
        SubCategories.CategoryName as SubCategoryName
      FROM Categories
      LEFT JOIN Categories SubCategories ON Categories.CategoryID = SubCategories.ParentCategoryID
      WHERE Categories.ParentCategoryID IS NULL
    `);

    // Gom các danh mục con vào danh mục cha
    const categories = result.recordset.reduce((acc, row) => {
      let category = acc.find(c => c.CategoryID === row.CategoryID);
      if (!category) {
        category = {
          CategoryID: row.CategoryID,
          CategoryName: row.CategoryName,
          subCategories: [],
        };
        acc.push(category);
      }
      if (row.SubCategoryID) {
        category.subCategories.push({
          SubCategoryID: row.SubCategoryID,
          SubCategoryName: row.SubCategoryName,
        });
      }
      return acc;
    }, []);

    res.status(200).json(categories);
  } catch (err) {
    console.error('Lỗi khi tải danh mục:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});

// API để lấy danh sách sản phẩm theo SubCategoryID
router.get('/productsBySubCategory/:subCategoryId', async (req, res) => {
  const { subCategoryId } = req.params;

  try {
    const pool = await poolPromise;
    const request = pool.request();
    
    // Query để lấy sản phẩm dựa trên SubCategoryID
    const result = await request
      .input('SubCategoryID', sql.Int, subCategoryId)
      .query('SELECT ProductName, Price, CONCAT(\'http://10.0.2.2:4000\', ImageURL) as ImageURL FROM Products WHERE CategoryID = @SubCategoryID');

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Không có sản phẩm nào cho danh mục con này.' });
    }

    res.status(200).json(result.recordset);
  } catch (err) {
    console.error('Lỗi khi lấy danh sách sản phẩm:', err);
    res.status(500).json({ message: 'Lỗi server: ' + err.message });
  }
});


// // Thêm đoạn này vào file routes của bạn (ví dụ: api.js hoặc routes.js)

// // API để lấy danh sách sản phẩm theo SubCategoryID
// router.get('/category/productsBySubCategory/:subCategoryId', async (req, res) => {
//   const { subCategoryId } = req.params;

//   try {
//     const pool = await poolPromise;
//     const request = pool.request();
    
//     // Query để lấy sản phẩm dựa trên SubCategoryID
//     const result = await request
//   .input('SubCategoryID', sql.Int, subCategoryId)
//   .query('SELECT ProductName, Price, ImageURL FROM Products WHERE CategoryID = @SubCategoryID');

    
//     if (result.recordset.length === 0) {
//       return res.status(404).json({ message: 'Không có sản phẩm nào cho danh mục con này.' });
//     }

//     res.status(200).json(result.recordset);
//   } catch (err) {
//     console.error('Lỗi khi lấy danh sách sản phẩm:', err);
//     res.status(500).json({ message: 'Lỗi server: ' + err.message });
//   }
// });


module.exports = router;
