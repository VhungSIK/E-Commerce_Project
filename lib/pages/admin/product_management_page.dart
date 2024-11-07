import 'package:flutter/material.dart';
import 'sub_category_page.dart'; // Trang danh mục con
import 'package:fbwa_app/services/api_service.dart'; // Dịch vụ gọi API

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  _ProductManagementPageState createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Map<String, dynamic>> categories = []; // Danh sách các danh mục cha

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Tải danh mục cha khi khởi động trang
  }

  // Hàm tải danh mục cha từ API
  Future<void> _loadCategories() async {
    try {
      List<Map<String, dynamic>> loadedCategories = await ApiService.getCategoriesWithId();
      setState(() {
        categories = loadedCategories; // Cập nhật danh mục cha
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh mục sản phẩm')),
      );
    }
  }

  // Hiển thị hộp thoại thêm danh mục cha mới
  Future<void> _showAddCategoryDialog() async {
    String newCategory = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm danh mục sản phẩm'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: const InputDecoration(hintText: 'Nhập tên danh mục'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (newCategory.isNotEmpty) {
                  // Gọi API để thêm danh mục cha
                  var response = await ApiService.addCategory(newCategory);
                  if (response['statusCode'] == 201) {
                    _loadCategories(); // Cập nhật lại danh sách danh mục
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm danh mục thành công')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'])),
                    );
                  }
                  Navigator.of(context).pop(); // Đóng dialog sau khi thêm
                }
              },
              child: const Text('Đồng ý'),
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
        title: const Text('Quản lý sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh mục sản phẩm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            categories.isEmpty
                ? const Text('Chưa có danh mục sản phẩm nào.')
                : Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(categories[index]['CategoryName']),
                          onTap: () {
                            // Chuyển hướng tới trang danh mục con
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SubCategoryPage(
                                  parentCategoryId: categories[index]['CategoryID'],
                                  parentCategoryName: categories[index]['CategoryName'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _showAddCategoryDialog, // Mở dialog để thêm danh mục cha mới
                child: const Text('Thêm danh mục sản phẩm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
