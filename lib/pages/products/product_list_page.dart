// lib/pages/products/product_list_page.dart

import 'package:flutter/material.dart';
import 'package:fbwa_app/services/api_service.dart';

class ProductListPage extends StatefulWidget {
  final int subCategoryId;

  const ProductListPage({super.key, required this.subCategoryId});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Hàm tải toàn bộ sản phẩm của danh mục con
  Future<void> _loadProducts() async {
    try {
      // Giả sử chúng ta có API để lấy sản phẩm của danh mục con
      List<Map<String, dynamic>> loadedProducts = await ApiService.getProductsBySubCategory(widget.subCategoryId);
      setState(() {
        products = loadedProducts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải sản phẩm')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Hiển thị 2 sản phẩm mỗi hàng
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75, // Tỷ lệ sản phẩm
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return _buildProductItem(product);
              },
            ),
    );
  }

  // Hàm xây dựng sản phẩm (ảnh, tên, giá)
  Widget _buildProductItem(Map<String, dynamic> product) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'http://10.0.2.2:4000${product['ImageURL']}', // Đường dẫn ảnh
            height: 100,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product['ProductName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('${product['Price']} VND'),
          ),
        ],
      ),
    );
  }
}
