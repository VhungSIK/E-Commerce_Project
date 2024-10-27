import 'package:fbwa_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'pages/splash/splash_page.dart';
import 'pages/auth/auth_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/home/home_page.dart';
import 'pages/admin/admin_home_page.dart';
import 'pages/admin/product_management_page.dart'; // Thêm trang quản lý sản phẩm

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FBWA App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/auth': (context) => const AuthPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/adminHome': (context) => const AdminHomePage(),
        '/admin/products': (context) => const ProductManagementPage(),
      },
    );
  }
}
// Trang kiểm tra đăng nhập
class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  _AuthCheckPageState createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    bool isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
