// lib/pages/admin/admin_home_page.dart
import 'package:flutter/material.dart';
import 'product_management_page.dart'; // Import trang quản lý sản phẩm

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Admin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Điều hướng đến trang quản lý sản phẩm
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductManagementPage()),
                );
              },
              child: const Text('Quản lý sản phẩm'),
            ),
            ElevatedButton(
              onPressed: () {
                // Chức năng quản lý đơn hàng (có thể thêm sau)
              },
              child: const Text('Quản lý đơn hàng'),
            ),
          ],
        ),
      ),
    );
  }
}
