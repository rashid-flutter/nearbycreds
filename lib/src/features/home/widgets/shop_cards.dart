import 'package:flutter/material.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/features/shop/model/shop_model.dart';
import 'package:go_router/go_router.dart';

class ShopCard extends StatefulWidget {
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
  _ShopCardState createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior:
                    Clip.antiAlias, // Ensure gradient and image clip to border
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6EE7B7), // Light teal
                        Color(0xFF3B82F6), // Blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Image
                      Image.network(
                        widget.shop.product.imageUrl ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 150,
                        errorBuilder: (_, __, ___) => Image.network(
                          'https://media.gettyimages.com/id/1437990851/photo/handsome-asian-male-searching-for-groceries-from-the-list-on-his-mobile-phone.jpg?s=612x612&w=gi&k=20&c=9wLzG-h9NP35vtiYPEwaiu0XhJEe7uE3aoiX4DFW-xc=',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.shop.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹ ${widget.shop.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.shop.product.description ??
                                  'No description',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.shop.active ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.shop.active
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: widget.isRedeemMode
                                  ? AppButton(
                                      label: widget.canRedeem
                                          ? 'Redeem'
                                          : 'Shop Now',
                                      icon: widget.canRedeem
                                          ? Icons.redeem
                                          : Icons.shopping_cart,
                                      color: widget.canRedeem
                                          ? Colors.blue
                                          : const Color.fromARGB(
                                              255, 11, 116, 14),
                                      isLoading: false,
                                      onPressed: widget.canRedeem
                                          ? widget.onRedeemPressed
                                          : () {
                                              context.push(
                                                  '/shop/${widget.shop.id}');
                                            },
                                    )
                                  : AppButton(
                                      label: 'Shop Now',
                                      icon: Icons.shopping_cart,
                                      color: const Color.fromARGB(
                                          255, 11, 116, 14),
                                      onPressed: () {
                                        context.push('/shop/${widget.shop.id}');
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
