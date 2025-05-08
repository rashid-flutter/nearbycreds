import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearbycreds/src/features/home/widgets/coin_card.dart';
import 'package:nearbycreds/src/features/home/widgets/shop_cards.dart';
import 'package:nearbycreds/src/features/profile/service/profile_provider.dart';
import 'package:nearbycreds/src/features/shop/service/shop_provider.dart';
import 'package:nearbycreds/src/features/profile/service/profile_service.dart'; // Profile service to fetch user data

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the shop provider to fetch all shops
    final shopAsync = ref.watch(allShopsProvider);

    // Fetch the user profile to get coins balance
    final userProfileAsync = ref.watch(
        profileProvider); // Assume profileProvider is defined elsewhere to get profile data

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Shops',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        actions: [
          userProfileAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.error),
            ),
            data: (profile) {
              if (profile == null) {
                return const SizedBox
                    .shrink(); // Or show an error/fallback widget
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Animated Coin Image
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 1.2),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Image.asset(
                              'assets/images/coin.png',
                              width: 24,
                              height: 24,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      // Animated Coin Balance
                      TweenAnimationBuilder<int>(
                        tween: IntTween(
                          begin: 0,
                          end: profile.coins ?? 0,
                        ),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allShopsProvider);
          ref.invalidate(profileProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: shopAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (shops) {
            return userProfileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error loading profile')),
              data: (profile) {
                return ListView(
                  children: [
                    CoinCard(coinBalance: profile?.coins ?? 0),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Shops",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...shops.map((shop) => ShopCard(shop: shop)).toList(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
