import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearbycreds/src/features/profile/model/profile_model.dart';
import 'package:nearbycreds/src/features/profile/service/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});


final profileProvider = FutureProvider<Profile?>((ref) async {
  final profileService = ProfileService();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    return  profileService.getProfile();  // Fetch the profile based on the user ID
  } else {
    throw Exception('User not logged in');
  }
});
