import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearbycreds/src/features/home/widgets/shop_cards.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';
import 'package:nearbycreds/src/features/shop/service/shop_service.dart';
import 'package:nearbycreds/src/features/profile/service/profile_service.dart';

class RedeemPage extends StatefulWidget {
  const RedeemPage({super.key});

  @override
  State<RedeemPage> createState() => _RedeemPageState();
}

class _RedeemPageState extends State<RedeemPage> {
  int userCoins = 0;
  List<Shop> shops = [];
  bool isLoading = true;

  final _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final coinBalance = userDoc.data()?['coins'] ?? 0;
    final shopList = await ShopService().getAllShops();

    setState(() {
      userCoins = coinBalance;
      shops = shopList;
      isLoading = false;
    });
  }

  Future<void> _handlePurchase(Shop shop) async {
    final price = shop.product.price.round();

    if (userCoins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins to redeem this product')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Redemption'),
        content: Text('Use $price coins to redeem "${shop.product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Deduct coins from the user's profile
      await _profileService.deductCoins(price);

      // 🔥 Create a new document in the 'redeem' collection
      await FirebaseFirestore.instance.collection('redeem').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'shopId': shop.id,
        'shopName': shop.name,
        'product': {
          'name': shop.product.name,
          'price': shop.product.price,
        },
        'redeemedAt': FieldValue.serverTimestamp(),
        'price': price,
      });

      setState(() {
        userCoins -= price;
        final shopIndex = shops.indexWhere((s) => s.id == shop.id);
        if (shopIndex != -1) {
          shops[shopIndex] = Shop(
            id: shop.id,
            name: shop.name,
            active: shop.active,
            redeem: true, // update the redeem status
            ownerId: shop.ownerId,
            createdAt: shop.createdAt,
            product: shop.product,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You redeemed ${shop.product.name} for $price coins!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to redeem product. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Redeem Coins')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Available Coins: $userCoins',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                final price = shop.product.price.round();

                return ShopCard(
                  shop: shop,
                  isRedeemMode: true,
                  canRedeem: userCoins >= price,
                  onRedeemPressed: () => _handlePurchase(shop),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
