import 'package:flutter/material.dart';
import 'package:fbwa_app/services/api_service.dart';
import 'package:fbwa_app/pages/admin/editProductPage.dart'; // Trang chỉnh sửa sản phẩm

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  // Hàm hiển thị hộp thoại xác nhận xóa sản phẩm
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại mà không xóa
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                bool success =
                    await ApiService.deleteProduct(product['ProductID']);
                if (success) {
                  Navigator.of(context).pop(); // Đóng hộp thoại
                  Navigator.of(context).pop(
                      true); // Quay lại trang trước và thông báo xóa thành công
                } else {
                  Navigator.of(context).pop(); // Đóng hộp thoại mà không xóa
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lỗi khi xóa sản phẩm')),
                  );
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['ProductName']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              product['ImageURL'] != null
                  ? Image.network(
                      'http://10.0.2.2:4000${product['ImageURL']}',
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 200),
              const SizedBox(height: 20),
              Text(
                product['ProductName'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                product['Description'] ?? 'Không có mô tả',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Giá: ${product['Price']} VND',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 10),
              Text(
                'Mã SKU: ${product['SKU']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                'Số lượng tồn kho: ${product['StockQuantity']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Ngày thêm sản phẩm: ${product['DateAdded']}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Điều hướng tới trang chỉnh sửa sản phẩm
                  ElevatedButton(
                    onPressed: () async {
                      bool productUpdated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProductPage(product: product),
                        ),
                      );

                      // Nếu sản phẩm đã được cập nhật thành công, trả về kết quả true để load lại trang
                      if (productUpdated == true) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text('Chỉnh sửa'),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationDialog(
                          context); // Hiển thị hộp thoại xác nhận xóa
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Xóa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
