import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';

class PaymentSuccessPage extends StatelessWidget {
  final int earnedCoins;

  const PaymentSuccessPage({super.key, required this.earnedCoins});

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Displaying payment success page with earned coins: $earnedCoins");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Successful"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: PaymentSuccessCard(earnedCoins: earnedCoins)),
            const SizedBox(height: 16),
            // Add other widgets or information if necessary
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: AppButton(
          label: 'Done',
          icon: Icons.check_circle,
          color: const Color.fromARGB(
              255, 11, 116, 14), // match your app's green theme
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
    );
  }
}

class PaymentSuccessCard extends StatefulWidget {
  final int earnedCoins;

  const PaymentSuccessCard({super.key, required this.earnedCoins});

  @override
  _PaymentSuccessCardState createState() => _PaymentSuccessCardState();
}

class _PaymentSuccessCardState extends State<PaymentSuccessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 3), // Adjust duration for rotation speed
    );

    // Create a rotation animation (spin around the Y-axis)
    _rotationAnimation = Tween<double>(
            begin: 0.0, end: 2 * 3.14159) // 360 degrees in radians
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Start the animation
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Displaying payment success card with earned coins: ${widget.earnedCoins}");

    return Card(
      color: Colors.green.shade100,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              "Payment Successful!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Apply rotation effect on coin image
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(_rotationAnimation.value),
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/coin.png', // Update with your actual asset path
                height: 60,
                width: 60,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You earned ${widget.earnedCoins} coins!",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
