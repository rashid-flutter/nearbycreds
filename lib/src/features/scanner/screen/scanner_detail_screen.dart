import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nearbycreds/src/core/util/widgets/app_button.dart';
import 'package:nearbycreds/src/core/util/widgets/app_text_field.dart';
import 'package:nearbycreds/src/features/pyments/services/pyment_service.dart';
import 'package:nearbycreds/src/features/pyments/widget/sucess_card.dart';
import 'package:nearbycreds/src/features/shop/service/shop_service.dart';

class ScannerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> parsedData;

  const ScannerDetailsScreen({super.key, required this.parsedData});

  @override
  _ScannerDetailsScreenState createState() => _ScannerDetailsScreenState();
}

class _ScannerDetailsScreenState extends State<ScannerDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();
  late String name; // Store merchant name to use in checkout

  @override
  void initState() {
    super.initState();
  }

  void _handleTransaction() {
    final String amountText = _amountController.text;

    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final int amount = int.tryParse(amountText) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Earned coins logic
    final int earnedCoins = amount ~/ 30;

    // ✅ Use parsed name from QR as the Razorpay name
    PaymentService().openCheckout(
      amount: amount,
      name: name,
      description: 'Payment via QR Scan',
      onPaymentSuccess: (int coinsEarned) {
        // Only navigate if payment is successful
        if (mounted) {
          context.push('/payment-success', extra: coinsEarned);
        }
      },
    );

    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final String upiUrl = widget.parsedData['rawCode'] ?? 'Unknown';
    final Uri upiUri = Uri.parse(upiUrl);
    final String upiID = upiUri.queryParameters['pa'] ?? 'Unknown';
    name = upiUri.queryParameters['pn'] ??
        'Unknown'; // ✅ Assign to instance variable
    final String amount = upiUri.queryParameters['amt'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Details")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display merchant name and UPI ID
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Name: $name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'UPI ID: $upiID',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),

          // Show amount if present in QR
          if (amount != 'Unknown')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Amount: ₹$amount',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Enter Amount:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppTextField(
              controller: _amountController,
              label: 'Amount',
              hintText: '100',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(height: 24),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            child: Center(
              child: AppButton(
                label: 'Pay',
                onPressed: _handleTransaction,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
