// lib/services/auth_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Đăng nhập và lưu thông tin người dùng
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.loginUser(email: email, password: password);

    if (response['statusCode'] == 200) {
      await _storage.write(key: 'token', value: response['body']['token']);
      await _storage.write(key: 'userId', value: response['body']['userId'].toString());
      await _storage.write(key: 'username', value: response['body']['username']);
      await _storage.write(key: 'role', value: response['body']['role']); // Lưu trữ role

      return {
        'statusCode': 200,
        'token': response['body']['token'],
        'userId': response['body']['userId'],
        'username': response['body']['username'],
        'role': response['body']['role'], // Trả về role
      };
    } else {
      return {
        'statusCode': response['statusCode']
      };
    }
  }

  // Kiểm tra xem người dùng đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    String? token = await _storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  // Đăng ký và tự động đăng nhập
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await ApiService.registerUser(
      username: username,
      email: email,
      password: password,
    );

    print('Phản hồi từ API: $response');

    if (response['statusCode'] == 201) {
      String? token = response['body']['token'];
      int? userId = response['body']['userId'];
      String? usernameRes = response['body']['username'];
      String? role = response['body']['role'];

      if (token != null && userId != null && usernameRes != null && role != null) {
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'userId', value: userId.toString());
        await _storage.write(key: 'username', value: usernameRes);
        await _storage.write(key: 'role', value: role);
        return true;
      } else {
        print("Lỗi: Giá trị từ API là null.");
        return false;
      }
    } else {
      print('Đăng ký thất bại với mã trạng thái: ${response['statusCode']}');
      return false;
    }
  }

  // Đăng xuất người dùng
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Lấy thông tin người dùng từ storage
  static Future<User?> getUser() async {
    String? userId = await _storage.read(key: 'userId');
    String? username = await _storage.read(key: 'username');
    String? email = await _storage.read(key: 'email');
    String? phone = await _storage.read(key: 'phone');
    String? firstName = await _storage.read(key: 'firstName');
    String? lastName = await _storage.read(key: 'lastName');
    String? role = await _storage.read(key: 'role');
    String? avatarUrl = await _storage.read(key: 'avatarUrl');

    if (userId != null && username != null && role != null) {
      return User(
        userId: int.parse(userId),
        username: username,
        email: email ?? '',
        phone: phone ?? '',
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        role: role,
        avatarUrl: avatarUrl ?? '',
      );
    }

    return null;
  }

  // Lấy token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Lấy thông tin người dùng từ server và lưu trữ
  static Future<User?> fetchUserDetails() async {
    String? token = await getToken();
    if (token == null) {
      return null;
    }

    final response = await ApiService.getUserDetails(token);
    if (response != null) {
      User user = User.fromJson(response);
      // Lưu trữ thông tin vào FlutterSecureStorage
      await _storage.write(key: 'username', value: user.username);
      await _storage.write(key: 'firstName', value: user.firstName);
      await _storage.write(key: 'lastName', value: user.lastName);
      await _storage.write(key: 'phone', value: user.phone);
      await _storage.write(key: 'avatarUrl', value: user.avatarUrl);
      await _storage.write(key: 'email', value: user.email);
      await _storage.write(key: 'role', value: user.role); // Lưu trữ role
      return user;
    }
    return null;
  }
}
