import 'package:nearbycreds/src/features/shop/model/shop_model.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearbycreds/src/features/shop/service/shop_service.dart';
import 'package:nearbycreds/src/features/profile/service/profile_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() => _instance;

  late final Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ShopService _shopService = ShopService();
  final ProfileService _profileService = ProfileService();

  int _paymentAmount = 0;
  String? _currentPaymentId;
  Function(int coinsEarned)? onPaymentSuccess;

  PaymentService._internal() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
    onPaymentSuccess = null;
  }

  String? _currentShopId;

  void openCheckout({
    required int amount,
    required String name,
    required String description,
    String? shopId, // Made optional
    required Function(int)
        onPaymentSuccess, // Add callback parameter for success
  }) async {
    try {
      _paymentAmount = amount;

      // Only set and fetch shop if provided
      Shop? shop;
      if (shopId != null) {
        _currentShopId = shopId;
        shop = await _shopService.getShopById(shopId);
        if (shop == null) {
          debugPrint('❌ No shop found with the given shopId!');
          return;
        }
      }

      final profile = await _profileService.getProfile();
      if (profile == null) {
        debugPrint('❌ No profile found for the current user!');
        return;
      }

      var options = {
        'key': 'rzp_test_h3G4D7fHQm3FGZ',
        'amount': amount * 100,
        'name': name,
        'description': description,
        'prefill': {
          'contact': profile.phone,
          'email': profile.email,
        },
        'method': {
          'netbanking': true,
          'cards': true,
          'upi': true,
          'wallets': true,
        },
        'theme': {'color': '#3399cc'}
      };

      // Razorpay payment success callback
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse response) {
        debugPrint('✅ Payment successful: ${response.paymentId}');
        // Trigger the success callback with earned coins (e.g. calculate from amount)
        final int earnedCoins = amount ~/ 30; // Example logic
        onPaymentSuccess(earnedCoins); // Call the callback with earned coins
      });

      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
          (PaymentFailureResponse response) {
        debugPrint('❌ Payment failed: ${response.message}');
        // Handle failure case
      });

      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
          (PaymentFailureResponse response) {
        debugPrint('❌ Payment cancelled');
        // Handle cancellation case
      });

      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ Error during checkout: $e');
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    debugPrint('✅ Payment Successful: ${response.paymentId}');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _currentPaymentId = response.paymentId;
    final coinsEarned = _paymentAmount ~/ 90;

    Shop? shop;
    if (_currentShopId != null) {
      shop = await _shopService.getShopById(_currentShopId!);
      if (shop == null) {
        debugPrint('❌ Shop not found for the payment!');
        return;
      }
    }

    // Store payment details with or without shop
    await _storePaymentDetails(
      response.paymentId!,
      userId,
      'success',
      coinsEarned,
      shop,
    );

    // Update the user's coin balance
    await _earnCoins(userId, _paymentAmount);

    if (onPaymentSuccess != null) {
      onPaymentSuccess!(coinsEarned);
    }
  }

  void _handleFailure(PaymentFailureResponse response) async {
    debugPrint('❌ Payment Failed: ${response.message}');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _currentPaymentId == null) return;

    await _storePaymentDetails(_currentPaymentId!, userId, 'failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('📱 External Wallet selected: ${response.walletName}');
  }

  Future<void> _storePaymentDetails(
    String paymentId,
    String userId,
    String status, [
    int? coinsEarned,
    Shop? shop,
  ]) async {
    try {
      final data = {
        'paymentId': paymentId,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        if (coinsEarned != null) 'coinsEarned': coinsEarned,
        if (shop != null) 'shopId': shop.id,
        if (shop != null) 'shopName': shop.name,
        if (shop != null) 'shopOwnerId': shop.ownerId,
      };

      await _firestore.collection('payments').add(data);
      debugPrint('📝 Payment details stored successfully!');
    } catch (e) {
      debugPrint('❌ Error storing payment details: $e');
    }
  }

  Future<void> _earnCoins(String userId, int amount) async {
    try {
      final coinsEarned = amount ~/ 30;

      final profileDoc = await _firestore.collection('users').doc(userId).get();
      if (!profileDoc.exists) {
        debugPrint('❌ User profile not found.');
        return;
      }

      final currentCoins = profileDoc.data()?['coins'] ?? 0;
      final newBalance = currentCoins + coinsEarned;

      await _firestore.collection('users').doc(userId).update({
        'coins': newBalance,
      });

      debugPrint('💰 Coins earned: $coinsEarned | New balance: $newBalance');
    } catch (e) {
      debugPrint('❌ Error updating coins: $e');
    }
  }
}
