import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearbycreds/src/features/shop/service/shop_service.dart';  // ShopService import
import 'package:nearbycreds/src/features/profile/service/profile_service.dart'; // Import ProfileService

class PaymentService {
  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ShopService _shopService = ShopService();
  final ProfileService _profileService = ProfileService(); // Profile service to get email/contact

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required int amount,
    required String name,
    required String description,
    required String shopId, // Pass shopId directly
  }) async {
    try {
      // Fetch the shop associated with the given shopId
      final shop = await _shopService.getShopById(shopId); // Fetch shop by shopId
      if (shop == null) {
        debugPrint('No shop found with the given shopId!');
        return;
      }

      // Fetch user profile to get the contact and email
      final profile = await _profileService.getProfile();
      if (profile == null) {
        debugPrint('No profile found for the current user!');
        return;
      }

      var options = {
        'key': 'rzp_test_h3G4D7fHQm3FGZ', // Test key
        'amount': amount * 100, // Amount in paise
        'name': name,
        'description': description,
        'prefill': {
          'contact': profile.phone, // Fetch contact from Profile
          'email': profile.email, // Fetch email from Profile
        },
        'external': {
          'wallets': [], // Leave it empty to allow all available wallets
        },
        'method': {
          'netbanking': true, // Allow Netbanking
          'cards': true, // Allow credit/debit cards
          'upi': true, // Allow UPI
          'wallets': true, // Allow wallets like Paytm, Google Pay, etc.
        },
        'theme': {
          'color': '#3399cc'
        }
      };

      _razorpay.open(options);

      // Store payment details in Firestore after the payment process
      await _storePaymentDetails(shopId, profile.userId); // Use userId here
      await _earnCoins(profile.userId, amount);  // Add coins to user's profile (userId instead of uid)
    } catch (e) {
      debugPrint('Error during checkout: $e');
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Successful: ${response.paymentId}');
    // Get payment details and save to Firestore
    await _storePaymentDetails(response.paymentId.toString(), 'dummy_user_id'); // Use actual userId here
  }

  void _handleFailure(PaymentFailureResponse response) {
    debugPrint('Payment Failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet selected: ${response.walletName}');
  }

  Future<void> _storePaymentDetails(String shopId, String userId) async {
    try {
      // Assuming payment is linked to a shop and you have the shopId directly
      var paymentData = {
        'paymentId': 'dummy_payment_id', // Use actual paymentId after successful payment
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
        'shopId': shopId,
        'userId': userId,
      };

      // Store payment details in Firestore
      await _firestore.collection('payments').add(paymentData);
      debugPrint('Payment details stored successfully!');
    } catch (e) {
      debugPrint('Error storing payment details: $e');
    }
  }

  Future<void> _earnCoins(String userId, int amount) async {
  try {
    // Calculate the number of coins based on the payment amount.
    final coinsEarned = amount ~/ 90;  // Example: Earn 1 coin per 10 units of currency

    // Fetch the current profile to get the current coin balance
    final profileDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    
    if (profileDoc.exists) {
      final profileData = profileDoc.data()!;
      final currentCoins = profileData['coins'] ?? 0;  // Get current coins from Firestore

      // Calculate the new coin balance
      final newCoinBalance = currentCoins + coinsEarned;

      // Update the coin balance in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'coins': newCoinBalance,  // Update coins field in Firestore
      });

      debugPrint('Coins earned: $coinsEarned. New balance: $newCoinBalance');
    } else {
      debugPrint('User profile not found.');
    }
  } catch (e) {
    debugPrint('Error updating coins: $e');
  }
}
}