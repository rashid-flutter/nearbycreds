import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbycreds/src/features/auth/screens/phone_login_scren.dart';
import 'package:nearbycreds/src/features/auth/screens/role_selection_screen.dart';
import 'package:nearbycreds/src/features/business_dashboard/business_main_screen.dart';
import 'package:nearbycreds/src/features/business_dashboard/pages/add_edit_shops.dart';
import 'package:nearbycreds/src/features/home/home_main_screen.dart';
import 'package:nearbycreds/src/features/home/screens/radeem_page.dart';
import 'package:nearbycreds/src/features/profile/pages/edit_profile_screen.dart';
import 'package:nearbycreds/src/features/profile/model/profile_model.dart';
import 'package:nearbycreds/src/features/pyments/widget/sucess_card.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';
import 'package:nearbycreds/src/features/shop/screens/shop_detail_page.dart';
import 'package:nearbycreds/src/features/shop/service/shop_service.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return '/login';

      // Check if we're already on login to avoid loop
      if (state.fullPath == '/login') {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final role = doc.data()?['role'] ?? 'customer';

        if (role == 'customer') {
          return '/home';
        } else {
          return '/business-dashboard'; // ✅ Includes bottom bar
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
//       GoRoute(
//   path: '/otp-screen',
//   builder: (context, state) {
//     final verificationId = state.extra as String;
//     return OtpScreen(verificationId: verificationId);
//   },
// ),
      GoRoute(
        path: '/select-role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),

      GoRoute(
        path: '/business-dashboard',
        builder: (context, state) => const BusinessMainScreen(),
      ),
      GoRoute(
        path: '/add-edit-shop',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return AddEditShopScreen(
            shopId: data?['shopId'],
            name: data?['name'],
            active: data?['active'] ?? true,
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final userData = state.extra as Map<String, dynamic>;

          // Convert the user data map to a Profile object
          final profile = Profile.fromFirestore(userData);

          return EditProfileScreen(userData: profile);
        },
      ),
      // Add the ShopDetailPage route
   GoRoute(
  path: '/shop/:shopId',
  builder: (context, state) {
    final shopId = state.pathParameters['shopId']!; // Get shopId from path parameters

    // Use ShopService to fetch shop details by shopId
    return FutureBuilder<Shop?>(
      future: ShopService().getShopById(shopId), // Fetch shop details
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Shop not found.'));
        }

        final shop = snapshot.data!; // Get the Shop object from snapshot

        return ShopDetailPage(shop: shop); // Pass the Shop object to the detail page
      },
    );
  },
),
GoRoute(
  path: '/redeem',
  builder: (context, state) => const RedeemPage(),
),
// GoRoute(
//   path: '/payment',
//   builder: (context, state) {
//     final data = state.extra as Map<String, dynamic>;

//     return PaymentPage(
//       shopId: data['shopId'],
//       amount: data['amount'],
//       name: data['name'],
//       description: data['description'],
//     );
//   },
// ),
GoRoute(
  path: '/payment-success',
  builder: (context, state) {
    final earnedCoins = state.extra as int;
    return PaymentSuccessPage(earnedCoins: earnedCoins);
  },
),


    ],
  );
}
