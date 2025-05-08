import 'dart:developer';

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
      if (user == null) {
        debugPrint('No user is logged in');
        setState(() {
          _loading = false;
        });
        return;
      }

      // ✅ Only fetch successful payments by the current user and sort by timestamp
      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'success')
          .where('userId', isEqualTo: user.uid)
          // ❌ Temporarily remove orderBy('timestamp') to avoid index error
          .get();

      debugPrint('Payments Snapshot: ${paymentsSnapshot.docs.length}');

      if (paymentsSnapshot.docs.isEmpty) {
        log('No successful payments found for the user');
      }

      final shopIds = paymentsSnapshot.docs
          .map((doc) {
            // Check if 'shopId' exists in the document
            if (doc.data().containsKey('shopId')) {
              return doc['shopId'] as String?;
            } else {
              log('No shopId field found in payment document: ${doc.id}');
              return null;
            }
          })
          .where((id) => id != null)
          .toSet();

      log('Shop IDs from payments: $shopIds');

      List<Shop> shops = [];
      for (final shopId in shopIds) {
        final shopDoc = await _firestore.collection('shops').doc(shopId).get();
        if (shopDoc.exists) {
          debugPrint('Found shop: $shopId');
          final shop = Shop.fromFirestore(shopDoc);
          shops.add(shop);
        } else {
          debugPrint('Shop not found for shopId: $shopId');
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
      body: RefreshIndicator(
        onRefresh: _loadPurchasedShops,
        child: _loading
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
      ),
    );
  }
}
