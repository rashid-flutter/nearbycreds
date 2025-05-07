import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';

class CoinCard extends StatefulWidget {
  final int coinBalance;

  const CoinCard({super.key, required this.coinBalance});

  @override
  _CoinCardState createState() => _CoinCardState();
}

class _CoinCardState extends State<CoinCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the ticker provider
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Set animation duration
    );

    // Slide animation from the bottom
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // Start below the screen
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Fade animation (opacity change)
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start the animation after the widget is built
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
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/coin.png',
                          width: 36,
                          height: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Coin Balance',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Animated coin amount
                              TweenAnimationBuilder<int>(
                                duration: const Duration(seconds: 1),
                                tween: IntTween(begin: 0, end: widget.coinBalance),
                                builder: (context, value, child) {
                                  return Text(
                                    '$value CN',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Redeem Coins',
                      icon: Icons.wallet_giftcard,
                      // color: Colors.green,
                      onPressed: () {
                        context.push('/redeem');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
