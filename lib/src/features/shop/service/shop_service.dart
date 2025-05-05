import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all shops from Firestore
  Future<List<Shop>> getAllShops() async {
    try {
      final querySnapshot = await _firestore.collection('shops').get();

      return querySnapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching shops: $e');
      rethrow;
    }
  }

  /// Fetch shops by ownerId (if needed)
  Future<List<Shop>> getShopsByOwner(String ownerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('shops')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return querySnapshot.docs.map((doc) => Shop.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching shops for owner: $e');
      rethrow;
    }
  }

  /// Fetch a single shop by its document ID
  Future<Shop?> getShopById(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();
      if (doc.exists) {
        return Shop.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching shop by ID: $e');
      rethrow;
    }
  }
}
