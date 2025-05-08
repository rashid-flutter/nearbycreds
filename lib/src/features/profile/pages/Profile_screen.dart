import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/features/auth/service/auth_service.dart';

import 'package:nearbycreds/src/features/profile/model/profile_model.dart';
import 'package:nearbycreds/src/features/profile/service/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileService = ref.watch(profileServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Profile')),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await profileService.getProfile();
        },
        child: FutureBuilder<Profile?>(
          // Call getProfile without any arguments
          future: profileService.getProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No user data found.'));
            }

            final profile = snapshot.data!;
            final name = profile.name ?? 'No Name';
            final phone = profile.phone ?? 'No Phone';
            final email = profile.email ?? 'No Email';
            final role = profile.role ?? 'No Role';
            final profileImageUrl = profile.profileImageUrl;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage(
                                  'assets/images/blank-profile-picture-973460_1280.webp') // Default image
                              as ImageProvider,
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      'Name: $name',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Phone Number
                    Text(
                      'Phone: $phone',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Text(
                      'Email: $email',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    // Role
                    Text(
                      'Role: $role',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Edit Button and Logout Button inside Row
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Edit Profile Button
                          Expanded(
                            child: AppButton(
                              label: 'Edit Profile',
                              icon: Icons.edit,
                              isLoading:
                                  false, // No loading state for this button
                              onPressed: () {
                                // Navigate to EditProfileScreen
                                GoRouter.of(context).push(
                                  '/edit-profile',
                                  extra: {
                                    'userId': profile.userId,
                                    'name': profile.name,
                                    'phone': profile.phone,
                                    'email': profile.email,
                                    'profileImageUrl': profile.profileImageUrl,
                                  },
                                );
                              },
                              color: Colors.blue, // Custom color for the button
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Logout Button
                          Expanded(
                            child: AppButton(
                              label: 'Logout',
                              icon: Icons.exit_to_app,
                              isLoading:
                                  false, // No loading state for this button
                              onPressed: () {
                                ref.read(authProvider).logout(context);
                              },
                              color: Colors
                                  .red, // Custom color for the logout button
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
