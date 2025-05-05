import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbycreds/src/features/home/widgets/shop_cards.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Shop> _purchasedShops = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchasedShops();
  }

  Future<void> _loadPurchasedShops() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // ✅ Only fetch successful payments by the current user
      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'success')
          .where('userId', isEqualTo: user.uid)
          .get();

      final shopIds = paymentsSnapshot.docs
          .map((doc) => doc['shopId'] as String?)
          .where((id) => id != null)
          .toSet();

      List<Shop> shops = [];
      for (final shopId in shopIds) {
        final shopDoc = await _firestore.collection('shops').doc(shopId).get();
        if (shopDoc.exists) {
          final shop = Shop.fromFirestore(shopDoc);
          shops.add(shop);
        }
      }

      setState(() {
        _purchasedShops = shops;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading purchased shops: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Cart (${_purchasedShops.length})'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _purchasedShops.isEmpty
              ? const Center(child: Text('No purchased shops found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _purchasedShops.length,
                  itemBuilder: (context, index) {
                    return ShopCard(shop: _purchasedShops[index]);
                  },
                ),
    );
  }
}
