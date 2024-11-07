// lib/pages/profile/profile_page.dart

import 'package:fbwa_app/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isEditing = false;
  bool _isLoading = true;

  // Controllers cho các trường thông tin
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Hàm tải thông tin người dùng
  Future<void> _loadUserInfo() async {
    User? user = await AuthService.fetchUserDetails();
    if (user != null) {
      setState(() {
        _user = user;
        _usernameController.text = user.username;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _phoneController.text = user.phone;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm cập nhật thông tin người dùng
  Future<void> _updateUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    String? token = await AuthService.getToken();

    if (token == null) {
      // Xử lý khi không có token
      return;
    }

    Map<String, dynamic> data = {
      'username': _usernameController.text.trim(),
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    bool success = await ApiService.updateUserProfile(data, token);

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (success) {
      await _loadUserInfo();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thất bại')),
      );
    }
  }

  // Hàm chuyển đổi giữa chế độ xem và chỉnh sửa
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Widget hiển thị ảnh đại diện (avatar)
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 50,
      backgroundImage: _user != null && _user!.avatarUrl.isNotEmpty
          ? NetworkImage(_user!.avatarUrl)
          : null,
      child: _user != null && _user!.avatarUrl.isEmpty
          ? const Icon(Icons.person, size: 50)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _user == null
            ? const Center(child: Text('Không có thông tin người dùng'))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      enabled: _isEditing,
                      decoration:
                          const InputDecoration(labelText: 'Tên đăng nhập'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _firstNameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(labelText: 'Họ'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _lastNameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(labelText: 'Tên'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      enabled: _isEditing,
                      decoration:
                          const InputDecoration(labelText: 'Số điện thoại'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: _user!.email),
                      enabled: false, // Không cho phép chỉnh sửa email
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(text: _user!.role),
                      enabled: false, // Không cho phép chỉnh sửa vai trò
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                    ),
                    const SizedBox(height: 20),
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _updateUserInfo,
                        child: const Text('Lưu'),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
