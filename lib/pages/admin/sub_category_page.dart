import 'package:fbwa_app/pages/admin/productListPage.dart';
import 'package:flutter/material.dart';
import 'package:fbwa_app/services/api_service.dart';

class SubCategoryPage extends StatefulWidget {
  final int parentCategoryId;
  final String parentCategoryName;

  const SubCategoryPage({super.key, required this.parentCategoryId, required this.parentCategoryName});

  @override
  _SubCategoryPageState createState() => _SubCategoryPageState();
}

class _SubCategoryPageState extends State<SubCategoryPage> {
  List<Map<String, dynamic>> subCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
  }

  // Hàm tải danh mục con từ API
  Future<void> _loadSubCategories() async {
    try {
      List<Map<String, dynamic>> loadedSubCategories = await ApiService.getSubCategories(widget.parentCategoryId);
      setState(() {
        subCategories = loadedSubCategories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi tải danh mục con')),
      );
    }
  }

  // Hàm thêm danh mục con
  Future<void> _addSubCategory(String categoryName) async {
    try {
      final response = await ApiService.addSubCategory(categoryName, widget.parentCategoryId);
      if (response['statusCode'] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm danh mục con thành công')),
        );
        _loadSubCategories(); // Tải lại danh mục sau khi thêm
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi thêm danh mục con')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi kết nối với server')),
      );
    }
  }

  // Hiển thị hộp thoại nhập tên danh mục con
  void _showAddSubCategoryDialog() {
    String categoryName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm danh mục con'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Tên danh mục con'),
            onChanged: (value) {
              categoryName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (categoryName.isNotEmpty) {
                  _addSubCategory(categoryName);
                }
              },
              child: const Text('Thêm'),
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
        title: Text('Danh mục con của ${widget.parentCategoryName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSubCategoryDialog, // Hiển thị hộp thoại thêm danh mục con
            tooltip: 'Thêm danh mục con',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh mục con',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            subCategories.isEmpty
                ? const Text('Chưa có danh mục con nào.')
                : Expanded(
                    child: ListView.builder(
                      itemCount: subCategories.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(subCategories[index]['CategoryName']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductListPage(
                                  categoryId: subCategories[index]['CategoryID'],
                                  categoryName: subCategories[index]['CategoryName'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubCategoryDialog,
        tooltip: 'Thêm danh mục con',
        child: const Icon(Icons.add),
      ),
    );
  }
}
