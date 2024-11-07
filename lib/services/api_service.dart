import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:4000'; // Địa chỉ của backend

 // Đăng ký người dùng
static Future<Map<String, dynamic>> registerUser({
  required String username,
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'), // Sửa đường dẫn
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    return {
      'statusCode': response.statusCode,
      'body': responseBody,
    };
  } catch (e) {
    print('Lỗi khi kết nối tới API: $e');
    return {
      'statusCode': 500,
      'body': {'message': 'Lỗi kết nối tới API'}
    };
  }
}

// Đăng nhập người dùng
static Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'), // Sửa đường dẫn
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    return {
      'statusCode': response.statusCode,
      'body': responseBody,
    };
  } catch (e) {
    print('Lỗi khi kết nối tới API: $e');
    return {
      'statusCode': 500,
      'body': {'message': 'Lỗi kết nối tới API'}
    };
  }
}


  // Phương thức lấy thông tin người dùng chi tiết (nếu cần)
  static Future<Map<String, dynamic>?> getUserDetails(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:4000/api/user/details'), // Đảm bảo endpoint này tồn tại trên server
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        return responseBody;
      } else {
        print('Lỗi lấy chi tiết người dùng: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi kết nối tới API: $e');
      return null;
    }
  }

  // // Đăng nhập người dùng
  // static Future<Map<String, dynamic>> loginUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/api/auth/login'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'email': email,
  //         'password': password,
  //       }),
  //     );

  //     final Map<String, dynamic> body = jsonDecode(response.body);

  //     return {
  //       'statusCode': response.statusCode,
  //       'body': body,
  //     };
  //   } catch (e) {
  //     print("Lỗi trong ApiService.loginUser(): $e");
  //     throw Exception('Đã xảy ra lỗi khi kết nối đến API');
  //   }
  // }

  // // Lấy thông tin người dùng
  // static Future<Map<String, dynamic>?> getUserDetails(String token) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/user/profile'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       print('Failed to fetch user details. Status code: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error fetching user details: $e');
  //     return null;
  //   }
  // }

  // Cập nhật thông tin người dùng
  static Future<bool> updateUserProfile(Map<String, dynamic> data, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update user profile. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Hàm thêm danh mục sản phẩm
  static Future<Map<String, dynamic>> addCategory(String categoryName) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/api/category/addCategory'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'categoryName': categoryName}),
      );

      if (response.statusCode == 201) {
        return {'statusCode': 201, 'message': 'Thêm danh mục thành công'};
      } else {
        return {
          'statusCode': response.statusCode,
          'message': jsonDecode(response.body)['message']
        };
      }
    } catch (e) {
      return {'statusCode': 500, 'message': 'Lỗi kết nối tới server'};
    }
  }

  // Hàm lấy danh sách danh mục sản phẩm
static Future<List<Map<String, dynamic>>> getCategoriesWithId() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/api/category/categories'), // URL API
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((category) => {
        'CategoryID': category['CategoryID'],
        'CategoryName': category['CategoryName']
      }).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  } catch (e) {
    throw Exception('Lỗi kết nối tới server');
  }
}


  // Hàm thêm danh mục con
  static Future<Map<String, dynamic>> addSubCategory(String categoryName, int parentCategoryId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/category/addSubCategory'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'categoryName': categoryName, 'parentCategoryId': parentCategoryId}),
      );

      if (response.statusCode == 201) {
        return {'statusCode': 201, 'message': 'Thêm danh mục con thành công'};
      } else {
        return {
          'statusCode': response.statusCode,
          'message': jsonDecode(response.body)['message']
        };
      }
    } catch (e) {
      return {'statusCode': 500, 'message': 'Lỗi kết nối tới server'};
    }
  }

  // Hàm lấy danh sách danh mục con theo ParentCategoryID
  static Future<List<Map<String, dynamic>>> getSubCategories(int parentCategoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/category/subCategories/$parentCategoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((category) => {
          'CategoryID': category['CategoryID'],
          'CategoryName': category['CategoryName']
        }).toList();
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối tới server');
    }
  }

  // Hàm tạo sản phẩm mới
  static Future<bool> createProduct({
    required String productName,
    required String description,
    required double price,
    required String sku,
    required int stockQuantity,
    required int categoryId,
    File? imageFile, // Ảnh sản phẩm
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/category/createProduct'),
      );

      // Thêm các thông tin sản phẩm vào request
      request.fields['productName'] = productName;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['sku'] = sku;
      request.fields['stockQuantity'] = stockQuantity.toString();
      request.fields['categoryId'] = categoryId.toString();

      // Nếu có ảnh, thêm file ảnh vào request
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Lỗi khi tạo sản phẩm: $e");
      return false;
    }
  }

  // Hàm lấy danh sách sản phẩm theo CategoryID
  static Future<List<Map<String, dynamic>>> getProductsByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/category/products/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((product) => product as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối tới server');
    }
  }
  // Hàm cập nhật sản phẩm
static Future<bool> updateProduct({
  required int productId,
  required String productName,
  required String description,
  required double price,
  required String sku,
  required int stockQuantity,
  File? imageFile,
}) async {
  try {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://10.0.2.2:4000/api/category/updateProduct/$productId'),
    );

    request.fields['productName'] = productName;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();  // Đảm bảo giá trị giá là chuỗi
    request.fields['sku'] = sku;
    request.fields['stockQuantity'] = stockQuantity.toString();

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Lỗi khi cập nhật sản phẩm. Mã lỗi: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Lỗi khi cập nhật sản phẩm: $e');
    return false;
  }
}


  // Hàm xóa sản phẩm
  static Future<bool> deleteProduct(int productId) async {
    try {
      final response = await http.delete(Uri.parse('http://10.0.2.2:4000/api/category/deleteProduct/$productId'));
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi xóa sản phẩm: $e');
      return false;
    }
  }
  // Lấy danh mục cha và con cùng sản phẩm
static Future<List<Map<String, dynamic>>> getCategoriesWithSubCategories() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/category/categoriesWithSubCategories'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((category) => category as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  } catch (e) {
    throw Exception('Error connecting to the server: $e');
  }
}


  
   // Hàm lấy danh sách sản phẩm theo SubCategoryID
  // services/api_service.dart
static Future<List<Map<String, dynamic>>> getProductsBySubCategory(int subCategoryId) async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/api/category/productsBySubCategory/$subCategoryId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((product) => product as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load products');
    }
  } catch (e) {
    throw Exception('Lỗi kết nối tới server: $e');
  }
}

}
