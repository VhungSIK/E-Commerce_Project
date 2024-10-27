import 'package:fbwa_app/pages/placeholder_page.dart';
import 'package:fbwa_app/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import 'home_content.dart'; // Import nội dung chính cho trang home

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = '';
  int _selectedIndex = 2; // Tab "Trang chủ" sẽ là tab mặc định

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Hàm để tải thông tin người dùng
  Future<void> _loadUserInfo() async {
    User? user = await AuthService.getUser();
    if (user != null) {
      setState(() {
        _username = user.username;
      });
    }
  }

  // Hàm để đăng xuất
  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  // Hàm xử lý khi nhấn vào các tab
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Xây dựng từng trang nội dung dựa trên tab được chọn
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const PlaceholderPage(title: 'Hoạt động');
      case 1:
        return const PlaceholderPage(title: 'Khuyến mãi');
      case 2:
        return HomeContentPage(username: _username); // Trang Home chính
      case 3:
        return const PlaceholderPage(title: 'Thông báo');
      case 4:
        return const ProfilePage();
      default:
        return const Center(child: Text('Tab không hợp lệ'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: _buildContent(), // Nội dung chính của từng trang
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blueAccent, // Màu icon khi được chọn
        unselectedItemColor: Colors.grey, // Màu icon khi không được chọn
        selectedFontSize: 14, // Kích thước chữ của tab được chọn
        unselectedFontSize: 12, // Kích thước chữ của tab không được chọn
        showSelectedLabels: true, // Hiển thị nhãn khi tab được chọn
        showUnselectedLabels: true, // Hiển thị nhãn khi tab không được chọn
        iconSize: 30, // Độ lớn của icon
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Hoạt động',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Khuyến mãi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed, // Đảm bảo tất cả các tab được hiển thị đầy đủ
      ),
    );
  }
}
