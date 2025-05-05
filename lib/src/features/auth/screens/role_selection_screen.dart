import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/core/util/widgets/app_text_field.dart';
import 'package:nearbycreds/src/features/profile/service/profile_provider.dart';
import 'package:nearbycreds/src/features/profile/service/profile_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      phoneController.text = user.phoneNumber ?? '';
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Submit role and profile details
  Future<void> _submitRole(String role, BuildContext context) async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Access ProfileService via the provider and save the profile
      await ref.read(profileServiceProvider).saveUserRole(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            context: context,
            phone: phone,
            role: role,
            image: _profileImage,
          );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );

      // Navigate to the next screen after profile save
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile image selection
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage(
                          'assets/images/blank-profile-picture-973460_1280.webp',
                        ) as ImageProvider,
                ),
              ),
              const SizedBox(height: 16),

              // Name text field
              AppTextField(
                controller: nameController,
                label: 'Enter your name',
                prefixIcon: Icons.person,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 8),

              // Email text field (readonly)
              AppTextField(
                controller: emailController,
                label: 'Your email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 8),
              AppTextField(
                controller: phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                readOnly: true,
              ),

              // // Phone number input field
              // IntlPhoneField(
              //   controller: phoneController,
              //   decoration: const InputDecoration(
              //     labelText: 'Phone Number',
              //     border: OutlineInputBorder(),
              //   ),
              //   initialCountryCode: 'IN',  // Set your desired initial country code
              //   onChanged: (phone) {
              //     // You can access the full number with the country code like this:
              //     String phoneNumberInE164 = phone.completeNumber;
              //     print(phoneNumberInE164);  // This is the properly formatted number
              //   },
              // ),

              const SizedBox(height: 8),

              // Continue as Customer button
              AppButton(
                label: 'Continue as Customer',
                icon: Icons.person,
                isLoading: _isLoading,
                onPressed: () => _submitRole('customer', context),
              ),
              const SizedBox(height: 12),

              // Continue as Business button
              AppButton(
                label: 'Continue as Business',
                icon: Icons.store,
                isLoading: _isLoading,
                onPressed: () => _submitRole('business', context),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
