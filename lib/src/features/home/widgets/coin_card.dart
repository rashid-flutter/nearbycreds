import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';

class CoinCard extends StatelessWidget {
  final int coinBalance;

  const CoinCard({super.key, required this.coinBalance});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      Text(
                        '$coinBalance CN',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Redeem',
              icon: Icons.wallet_giftcard,
              // color: Colors.green,
            onPressed: () {
  context.push('/redeem');
},

            ),
          ],
        ),
      ),
    );
  }
}
