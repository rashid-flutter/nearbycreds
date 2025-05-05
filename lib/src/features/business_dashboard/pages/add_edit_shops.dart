import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/core/util/widgets/app_text_field.dart';

class AddEditShopScreen extends StatefulWidget {
  final String? shopId;
  final String? name;
  final bool active;
  final VoidCallback? onSubmitSuccess;  // Add callback to notify parent

  const AddEditShopScreen({
    super.key,
    this.shopId,
    this.name,
    this.active = true,
    this.onSubmitSuccess,  // Pass callback to parent
  });

  @override
  State<AddEditShopScreen> createState() => _AddEditShopScreenState();
}

class _AddEditShopScreenState extends State<AddEditShopScreen> {
  final _nameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productDescController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  File? _pickedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name ?? '';
    _isActive = widget.active;

    if (widget.shopId != null) {
      _fetchShopData(widget.shopId!);
    }
  }

  Future<void> _fetchShopData(String shopId) async {
    final shopSnapshot =
        await FirebaseFirestore.instance.collection('shops').doc(shopId).get();

    if (shopSnapshot.exists) {
      final shopData = shopSnapshot.data() as Map<String, dynamic>;
      _productNameController.text = shopData['product']['name'] ?? '';
      _productDescController.text = shopData['product']['description'] ?? '';
      _priceController.text = shopData['product']['price']?.toString() ?? '';
      _existingImageUrl = shopData['product']['imageUrl'];

      setState(() {
        _pickedImage = null; // don't load the image from Firestore until needed
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref('product_images/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    final shopName = _nameController.text.trim();
    final productName = _productNameController.text.trim();
    final productDesc = _productDescController.text.trim();
    final priceText = _priceController.text.trim();

    if (shopName.isEmpty ||
        productName.isEmpty ||
        productDesc.isEmpty ||
        priceText.isEmpty) {
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null) return;

    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final shops = FirebaseFirestore.instance.collection('shops');

    // Upload product image if a new image is picked
    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _uploadImage(_pickedImage!);
    } else {
      imageUrl =
          _existingImageUrl; // Keep the existing image URL if no new image is picked
    }

    final shopData = {
      'name': shopName,
      'active': _isActive,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'product': {
        'name': productName,
        'description': productDesc,
        'price': price,
        'imageUrl': imageUrl,
      },
    };

    if (widget.shopId != null) {
      // Update existing shop
      await shops.doc(widget.shopId).update(shopData);
    } else {
      // Add new shop
      await shops.add(shopData);
    }

    // Call the parent callback to notify the submission was successful
    if (widget.onSubmitSuccess != null) {
      widget.onSubmitSuccess!(); // Notify parent to switch back to the dashboard
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.shopId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Shop' : 'Add Shop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Profile image display
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : _existingImageUrl != null
                          ? NetworkImage(_existingImageUrl!) as ImageProvider
                          : const AssetImage(
                              'assets/images/blank-profile-picture-973460_1280.webp'),
                ),

                // Camera icon with optional mini-preview of new image
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: _pickedImage == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.blue,
                            )
                          : ClipOval(
                              child: Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                                width: 36,
                                height: 36,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _nameController,
              label: 'Shop Name',
              prefixIcon: Icons.store,
              autoFocus: true,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active'),
                Switch(
                  activeColor: const Color.fromARGB(255, 0, 124, 4),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text(
              "Product Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            AppTextField(
              controller: _productNameController,
              label: 'Product Name',
              prefixIcon: Icons.label,
            ),
            const SizedBox(height: 10),

            AppTextField(
              controller: _productDescController,
              label: 'Product Description',
              maxLines: 3,
              prefixIcon: Icons.description,
            ),
            const SizedBox(height: 10),

            AppTextField(
              controller: _priceController,
              label: 'Product Price',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
            ),

            const SizedBox(height: 20),
            AppButton(
              label: isEdit ? 'Update Shop & Product' : 'Create Shop & Product',
              icon: isEdit ? Icons.edit : Icons.add,
              isLoading: _isLoading,
              onPressed: _submit,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
