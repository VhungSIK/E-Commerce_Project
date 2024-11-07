import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fbwa_app/services/api_service.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductPage({super.key, required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.product['ProductName'];
    _descriptionController.text = widget.product['Description'] ?? '';
    _priceController.text = widget.product['Price'].toString();
    _skuController.text = widget.product['SKU'];
    _stockQuantityController.text = widget.product['StockQuantity'].toString();
  }

  // Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Lưu sản phẩm sau khi chỉnh sửa
  Future<void> _saveProduct() async {
  if (_formKey.currentState!.validate()) {
    try {
      String sanitizedPrice = _priceController.text.replaceAll('.', '');
      double price = double.parse(sanitizedPrice);

      bool success = await ApiService.updateProduct(
        productId: widget.product['ProductID'],
        productName: _productNameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        sku: _skuController.text.trim(),
        stockQuantity: int.parse(_stockQuantityController.text),
        imageFile: _selectedImage,
      );

      if (success) {
        Navigator.of(context).pop(true); // Trả về true khi lưu thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi lưu sản phẩm')),
        );
      }
    } catch (e) {
      print("Lỗi khi lưu sản phẩm: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Định dạng dữ liệu không hợp lệ')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm'),
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
                  ? (widget.product['ImageURL'] != null
                      ? Image.network(
                          'http://10.0.2.2:4000${widget.product['ImageURL']}',
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const Text('Chưa chọn hình ảnh'))
                  : Image.file(_selectedImage!, height: 200),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Chọn ảnh sản phẩm'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
