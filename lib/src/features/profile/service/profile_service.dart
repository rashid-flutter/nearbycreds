import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nearbycreds/src/features/profile/model/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new profile (called after user registration)
  Future<void> addProfile(Profile profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user logged in.");
      }

      // Adding the profile data to Firestore
      await _firestore.collection('users').doc(user.uid).set(profile.toMap());
    } catch (e) {
      print('Error adding profile: $e');
      rethrow;
    }
  }

  // Update the profile (called when user updates their profile)
  Future<void> updateProfile(Profile profile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user logged in.");
      }

      // Update the profile data in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(profile.toMap());
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Fetch the current user's profile
  // Fetch the user profile from Firestore
  Future<Profile?> getProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user logged in.");
      }

      // Fetch the user profile data from Firestore
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        return Profile.fromFirestore(
            docSnapshot.data() as Map<String, dynamic>);
      } else {
        return null; // No profile found for the user
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Method to save user profile to Firestore
  Future<void> saveUserRole({
    required String name,
    required String phone,
    required String role,
    required BuildContext context,
    required String email,
    required File? image,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      String? profileImageUrl;

      // Upload image if available
      if (image != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(fileName);
        await ref.putFile(image);
        profileImageUrl = await ref.getDownloadURL();
      }

      // Create a Profile object
      final profile = Profile(
        userId: user.uid,
        name: name,
        phone: phone,
        email: email,
        profileImageUrl: profileImageUrl,
        role: role,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap());

      // Update Firebase Auth display name
      await user.updateDisplayName(name);

      // Navigate based on role
      if (context.mounted) {
        if (role == 'customer') {
          context.go('/home');
        } else if (role == 'business') {
          context.go('/business-dashboard');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save user data: $e')),
        );
      }
    }

    // Method to upload the profile image to Firebase Storage
    Future<String> _uploadProfileImage(File image) async {
      try {
        // Generate a unique file name using the current timestamp
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Reference to Firebase Storage
        Reference storageRef =
            FirebaseStorage.instance.ref().child('profile_images/$fileName');

        // Upload the file
        await storageRef.putFile(image);

        // Get the download URL of the uploaded image
        return await storageRef.getDownloadURL();
      } catch (e) {
        throw Exception("Error uploading profile image: $e");
      }
    }
  }

// Method to deduct coins from the user's balance
  Future<void> deductCoins(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in.");

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'coins': FieldValue.increment(-amount)});
    } catch (e) {
      throw Exception("Error deducting coins: $e");
    }
  }
}
