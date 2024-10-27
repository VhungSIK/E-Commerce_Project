import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fbwa_app/services/api_service.dart';

class CreateProductPage extends StatefulWidget {
  final int categoryId;

  const CreateProductPage({super.key, required this.categoryId});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  File? _selectedImage;

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Hàm tạo sản phẩm
  Future<void> _createProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Loại bỏ dấu phân cách hàng nghìn và parse giá
        String sanitizedPrice = _priceController.text.replaceAll('.', '');
        double price = double.parse(sanitizedPrice);

        // In ra các giá trị để kiểm tra trước khi gọi API
        print("Product Name: ${_productNameController.text.trim()}");
        print("Description: ${_descriptionController.text.trim()}");
        print("Price: $price");
        print("SKU: ${_skuController.text.trim()}");
        print("Stock Quantity: ${_stockQuantityController.text}");
        print("Category ID: ${widget.categoryId}");
        print("Selected Image: $_selectedImage");

        bool success = await ApiService.createProduct(
          productName: _productNameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price, // Giá đã được xử lý
          sku: _skuController.text.trim(),
          stockQuantity: int.parse(_stockQuantityController.text),
          categoryId: widget.categoryId,
          imageFile: _selectedImage,
        );

        if (success) {
          Navigator.of(context).pop(true); // Quay lại và báo tạo thành công
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi khi tạo sản phẩm')),
          );
        }
      } catch (e) {
        print("Lỗi tạo sản phẩm: $e"); // In ra lỗi để kiểm tra
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Định dạng giá không hợp lệ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo sản phẩm mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập giá' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'Mã SKU'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập SKU' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(labelText: 'Số lượng tồn kho'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập số lượng tồn kho' : null,
              ),
              const SizedBox(height: 20),
              _selectedImage == null
                  ? const Text('Chưa chọn hình ảnh')
                  : Image.file(_selectedImage!, height: 200),
              ElevatedButton(
                onPressed: _pickImage, // Chọn ảnh từ thư viện
                child: const Text('Chọn ảnh sản phẩm'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createProduct, // Tạo sản phẩm
                child: const Text('Tạo sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
