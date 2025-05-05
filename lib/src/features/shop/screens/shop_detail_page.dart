import 'package:flutter/material.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/features/business_dashboard/functins.dart';
import 'package:nearbycreds/src/features/pyments/services/pyment_service.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';

class ShopDetailPage extends StatelessWidget {
  final Shop shop;

  const ShopDetailPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(shop.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
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
              // Name
              Text(
                shop.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Price
              Text(
                '₹ ${shop.product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const SizedBox(height: 8),
              // Description
              Text(shop.product.description ?? 'No description available'),
              const SizedBox(height: 8),
              // Status
              Text(
                shop.active ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 18,
                  color: shop.active
                      ? const Color.fromARGB(255, 11, 116, 14)
                      : const Color.fromARGB(255, 179, 12, 0),
                ),
              ),
              const SizedBox(height: 10),
              // Product name
              Text(
                shop.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(shop.product.description ?? ''),
              const SizedBox(height: 10),
              Text('Posted on: ${formatDateWithRelative(shop.createdAt)}'),
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
          onPressed: () {
            // Trigger payment process using PaymentService
            PaymentService().openCheckout(
              amount: (shop.product.price * 5).toInt(), // Convert price to paise
              name: shop.product.name,
              description: shop.product.description ?? 'Product Description',
             
              shopId: shop.id, // Pass the shopId to the payment service
            );
          },
        ),
      ),
    );
  }
}
