import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final authProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService(this.ref);
  Future<void> registerWithEmail(String email, String password, BuildContext context) async {
  try {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    _handlePostLogin(context); // optionally go to select-role
  } on FirebaseAuthException catch (e) {
    String message = 'Registration failed.';
    if (e.code == 'email-already-in-use') {
      message = 'An account already exists for that email.';
    } else if (e.code == 'weak-password') {
      message = 'The password is too weak.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

Future<void> loginWithEmail(String email, String password, BuildContext context) async {
  try {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    _handlePostLogin(context);
  } on FirebaseAuthException catch (e) {
    String message = 'Login failed. Please try again.';
    if (e.code == 'user-not-found') {
      message = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      message = 'Incorrect password.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

  void verifyPhone(String phone, BuildContext context) {
  _auth.verifyPhoneNumber(
    phoneNumber: phone,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
      _handlePostLogin(context);
    },
    verificationFailed: (FirebaseAuthException e) {
      String message = 'Verification failed. Please try again.';
      if (e.code == 'invalid-phone-number') {
        message = 'The phone number entered is invalid.';
      } else if (e.code == 'quota-exceeded') {
        message = 'The phone number verification quota has been exceeded. Try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    },
    codeSent: (String verificationId, int? resendToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          // Navigate to OTP screen as soon as the OTP is sent
          GoRouter.of(context).go('/otp-screen', extra: verificationId);
        }
      });
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      log('Timeout: $verificationId');
    },
  );
}

  Future<void> verifyOtp(String otp, String verificationId, BuildContext context) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      _handlePostLogin(context);
    } catch (e) {
      log('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP! Please try again.')),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    // Navigate to login screen after logout
    GoRouter.of(context).go('/login');
  }

  Future<void> _handlePostLogin(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      // First time login → choose role
      GoRouter.of(context).go('/select-role');
    } else {
      final role = userDoc['role'];
      if (role == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role not defined in Firestore. Please contact support.')),
        );
        return;
      }
      if (role == 'customer') {
        GoRouter.of(context).go('/home');
      } else if (role == 'business') {
        GoRouter.of(context).go('/business-dashboard');
      } else {
        GoRouter.of(context).go('/select-role');
      }
    }
  }

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
      if (user == null) return;

      String? profileImageUrl;

      if (image != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(fileName);
        await ref.putFile(image);
        profileImageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'profileImageUrl': profileImageUrl ?? '',
      });

      // Redirect to home or dashboard
      if (context.mounted) {
        if (role == 'customer') {
          context.go('/home');
        } else if (role == 'business') {
          context.go('/business-dashboard');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data: $e')),
      );
    }
  }
}
