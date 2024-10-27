import 'package:flutter/material.dart';
import 'package:fbwa_app/services/api_service.dart';

class HomeContentPage extends StatelessWidget {
  final String username;

  const HomeContentPage({super.key, required this.username});

  Future<List<Map<String, dynamic>>> _fetchCategoriesWithSubCategories() async {
    try {
      List<Map<String, dynamic>> categories = await ApiService.getCategoriesWithSubCategories();
      print("Danh mục đã tải: $categories");
      return categories;
    } catch (e) {
      print("Lỗi khi tải danh mục: $e");
      throw Exception("Lỗi khi tải danh mục");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProductsBySubCategory(int subCategoryId) async {
    try {
      List<Map<String, dynamic>> products = await ApiService.getProductsBySubCategory(subCategoryId);
      print("Sản phẩm của danh mục con đã tải: $products");
      return products;
    } catch (e) {
      print("Lỗi khi tải sản phẩm: $e");
      throw Exception("Lỗi khi tải sản phẩm");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCategoriesWithSubCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Lỗi khi tải danh mục'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có danh mục nào.'));
        }

        final categories = snapshot.data!;

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final subCategories = category['subCategories'] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị tên danh mục cha
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category['CategoryName'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (subCategories.isNotEmpty) ...[
                  // Sử dụng toán tử trải để thêm danh sách widget
                  for (var subCategory in subCategories) ...[
                    // Hiển thị tên danh mục con
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        subCategory['SubCategoryName'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Hiển thị danh sách sản phẩm
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchProductsBySubCategory(subCategory['SubCategoryID']),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (productSnapshot.hasError) {
                          return const Center(child: Text('Lỗi khi tải sản phẩm'));
                        }

                        final products = productSnapshot.data ?? [];

                        if (products.isEmpty) {
                          return const SizedBox(); // Không hiển thị gì nếu không có sản phẩm
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, productIndex) {
                                final product = products[productIndex];
                                return GestureDetector(
                                  onTap: () {
                                    // Điều hướng tới chi tiết sản phẩm (nếu cần)
                                  },
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Image.network(
                                          product['ImageURL'], // Sử dụng URL đã hoàn chỉnh
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            product['ProductName'],
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Text('Giá: ${product['Price']} VND'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/subCategoryProducts', arguments: subCategory);
                                },
                                child: const Text('Xem thêm'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ] else
                  const Center(child: Text('Không có danh mục con')),
              ],
            );
          },
        );
      },
    );
  }
}
