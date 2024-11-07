import 'package:flutter/material.dart';
import 'package:fbwa_app/pages/admin/createProductPage.dart';
import 'package:fbwa_app/pages/admin/productDetailPage.dart'; // Import trang chi tiết sản phẩm
import 'package:fbwa_app/services/api_service.dart';

class ProductListPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductListPage({super.key, required this.categoryId, required this.categoryName});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> products = []; // Danh sách sản phẩm

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Tải danh sách sản phẩm khi trang mở
  }

  // Hàm tải danh sách sản phẩm từ API
  Future<void> _loadProducts() async {
    try {
      List<Map<String, dynamic>> loadedProducts = await ApiService.getProductsByCategory(widget.categoryId);
      setState(() {
        products = loadedProducts; // Cập nhật danh sách sản phẩm
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh sách sản phẩm')),
      );
    }
  }

  // Phương thức này sẽ được gọi lại khi trang trước (như trang chi tiết) được popped
  void didPopNext() {
    _loadProducts(); // Tải lại danh sách sản phẩm khi trang này được hiện lại
  }

  // Điều hướng sang trang tạo sản phẩm
  void _navigateToCreateProductPage() async {
    bool productCreated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProductPage(categoryId: widget.categoryId),
      ),
    );

    // Nếu sản phẩm đã được tạo thành công, cập nhật lại danh sách sản phẩm
    if (productCreated == true) {
      _loadProducts(); // Tải lại danh sách sản phẩm
    }
  }

 void _navigateToProductDetailPage(Map<String, dynamic> product) async {
  bool productUpdatedOrDeleted = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailPage(product: product),
    ),
  );

  // Nếu sản phẩm đã được cập nhật hoặc xóa, tải lại danh sách sản phẩm
  if (productUpdatedOrDeleted == true) {
    _loadProducts(); // Tải lại danh sách sản phẩm
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm trong danh mục ${widget.categoryName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách sản phẩm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            products.isEmpty
                ? const Text('Chưa có sản phẩm nào trong danh mục này.')
                : Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Hiển thị 2 sản phẩm trên mỗi hàng
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75, // Điều chỉnh tỷ lệ hiển thị
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _navigateToProductDetailPage(products[index]); // Chuyển sang trang chi tiết sản phẩm
                          },
                          child: Card(
                            child: Column(
                              children: [
                                products[index]['ImageURL'] != null
                                    ? Image.network(
                                        'http://10.0.2.2:4000${products[index]['ImageURL']}',
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : const Placeholder(fallbackHeight: 100),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        products[index]['ProductName'],
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text('Giá: ${products[index]['Price']} VND'),
                                      Text('Số lượng: ${products[index]['StockQuantity']}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _navigateToCreateProductPage, // Chuyển hướng tới trang tạo sản phẩm
                child: const Text('Thêm sản phẩm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
