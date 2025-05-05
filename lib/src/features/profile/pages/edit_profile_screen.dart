import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/core/util/widgets/app_text_field.dart';

import 'package:nearbycreds/src/features/profile/model/profile_model.dart';
import 'package:nearbycreds/src/features/profile/service/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final Profile userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  File? _profileImage; // Nullable profile image

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _phoneController = TextEditingController(text: widget.userData.phone);
    _emailController = TextEditingController(text: widget.userData.email);
  }

  bool _isPickingImage = false; // Prevent multiple calls

  // Function to pick a new profile image
  Future<void> _pickProfileImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image picking error: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  // Function to upload image to Firebase Storage
  Future<String?> _uploadProfileImage(File image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Function to update user profile
  Future<void> _updateProfile() async {
    String? profileImageUrl;
    if (_profileImage != null) {
      profileImageUrl = await _uploadProfileImage(_profileImage!);
      if (profileImageUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error uploading profile image')),
        );
        return;
      }
    }

    final updatedProfile = Profile(
      userId: widget.userData.userId,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      profileImageUrl: profileImageUrl ?? widget.userData.profileImageUrl,
    );

    final profileService = ref.read(profileServiceProvider);
    try {
      await profileService.updateProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      if (context.mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : NetworkImage(widget.userData.profileImageUrl ?? '')
                          as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            AppTextField(
              controller: _nameController,
              label: "Name",
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 8),

            // Phone Number
            AppTextField(
              controller: _phoneController,
              label: "Phone Number",
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
              readOnly: true,

            ),
            const SizedBox(height: 8),

            // Email
            AppTextField(
              controller: _emailController,
              label: "Email",
              // keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 16),

            // Save Button
            Center(
              child: AppButton(
                label: 'Save Changes',
                icon: Icons.save,
                isLoading: false,
                color: Colors.blue,
                onPressed: _updateProfile,
              ),
            )
          ],
        ),
      ),
    );
  }
}
