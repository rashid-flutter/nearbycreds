import 'package:flutter/material.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';
import 'package:go_router/go_router.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final bool isRedeemMode;
  final bool canRedeem;
  final VoidCallback? onRedeemPressed;

  const ShopCard({
    super.key,
    required this.shop,
    this.isRedeemMode = false,
    this.canRedeem = false,
    this.onRedeemPressed,
  });

  @override
  Widget build(BuildContext context) {
    final price = shop.product.price.round();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                shop.product.imageUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150,
                errorBuilder: (_, __, ___) =>Image.network(
                 'https://media.gettyimages.com/id/1437990851/photo/handsome-asian-male-searching-for-groceries-from-the-list-on-his-mobile-phone.jpg?s=612x612&w=gi&k=20&c=9wLzG-h9NP35vtiYPEwaiu0XhJEe7uE3aoiX4DFW-xc=',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 150,
              ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₹ ${shop.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(shop.product.description ?? 'No description',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(
                    shop.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: shop.active ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: isRedeemMode
                        ? AppButton(
                            label: canRedeem ? 'Redeem' : 'Shop Now',
                            icon:
                                canRedeem ? Icons.redeem : Icons.shopping_cart,
                            color: canRedeem
                                ? Colors
                                    .blue // You can customize this color for the "Redeem" button
                                : const Color.fromARGB(255, 11, 116, 14),
                            isLoading:
                                false, // Set to true if there's a loading state
                            onPressed: canRedeem
                                ? onRedeemPressed
                                : () {
                                    context.push('/shop/${shop.id}');
                                  },
                          )
                        : AppButton(
                            label: 'Shop Now',
                            icon: Icons.shopping_cart,
                            color: const Color.fromARGB(255, 11, 116, 14),
                            onPressed: () {
                              context.push('/shop/${shop.id}');
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
