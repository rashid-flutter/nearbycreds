import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/features/pyments/services/pyment_service.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';

class ShopDetailPage extends StatefulWidget {
  final Shop shop;

  const ShopDetailPage({super.key, required this.shop});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  late final PaymentService paymentService;

@override
void initState() {
  super.initState();

  paymentService = PaymentService(); // ✅ Singleton instance

  // ✅ Set callback using the singleton instance
  paymentService.onPaymentSuccess = (int coinsEarned) {
    log("Coins earned: $coinsEarned");

    if (mounted) {
      context.push('/payment-success', extra: coinsEarned); // ✅ Navigation
    }
  };
}

@override
void dispose() {
  paymentService.onPaymentSuccess = null; // ✅ Clean up
  super.dispose();
}

  

  void _handlePayment() {
    PaymentService().openCheckout(
      amount: widget.shop.product.price.toInt(),
      name: widget.shop.product.name,
      description: widget.shop.product.description ?? 'Product Description',
      shopId: widget.shop.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return Scaffold(
      appBar: AppBar(title: Text(shop.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  shop.product.imageUrl ??
                      'https://media.gettyimages.com/id/1437990851/photo/handsome-asian-male-searching-for-groceries-from-the-list-on-his-mobile-phone.jpg?s=612x612&w=gi&k=20&c=9wLzG-h9NP35vtiYPEwaiu0XhJEe7uE3aoiX4DFW-xc=',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shop.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '₹ ${shop.product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Text(shop.product.description ?? 'No description available'),
              const SizedBox(height: 8),
              Text(
                shop.active ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 18,
                  color: shop.active
                      ? const Color.fromARGB(255, 11, 116, 14)
                      : const Color.fromARGB(255, 179, 12, 0),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          label: 'Shop Now',
          color: const Color.fromARGB(255, 11, 116, 14),
          icon: Icons.shopping_cart,
          onPressed: _handlePayment,
        ),
      ),
    );
  }
}
