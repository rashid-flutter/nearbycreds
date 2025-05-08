import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearbycreds/src/features/business_dashboard/functins.dart';

class RedeemHistoryPage extends StatefulWidget {
  const RedeemHistoryPage({super.key});

  @override
  _RedeemHistoryPageState createState() => _RedeemHistoryPageState();
}

class _RedeemHistoryPageState extends State<RedeemHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  double totalRedeemedCoins = 0.0;
  late Stream<QuerySnapshot> _redeemedStream;
  ValueNotifier<double> coinBalanceNotifier =
      ValueNotifier<double>(0.0); // Notifier for coin balance

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the ticker provider
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });

    _redeemedStream = _getRedeemedShops();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getRedeemedShops() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('redeem')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  void _calculateTotalRedeemedCoins(QuerySnapshot snapshot) {
    double total = 0.0;

    final docs = snapshot.docs;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final product = data['product'] ?? {};
      final price = product['price'] ?? 0;
      total += price.toDouble();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          totalRedeemedCoins = total;
          coinBalanceNotifier.value =
              total; // Update the ValueNotifier with the new total
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redeem History')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coin Image and Total Redeemed Coins Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Coin Image
                Image.asset(
                  'assets/images/coin.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                // Total Redeemed Coins Text
                Expanded(
                  child: Text(
                    'Total Redeemed Coins: ₹${totalRedeemedCoins.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Redeemed History List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _redeemedStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No redemptions found.'));
                }

                _calculateTotalRedeemedCoins(snapshot.data!);
                final docs = snapshot.data!.docs;

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final product = data['product'] ?? {};
                            final productName =
                                product['name'] ?? 'Unknown Product';
                            final price = (product['price'] ?? 0).toString();
                            final redeemedAt =
                                (data['redeemedAt'] as Timestamp?)?.toDate() ??
                                    DateTime.now();

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade300,
                                      Colors.blue.shade100
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.redeem),
                                  title: Text(productName),
                                  subtitle: Text(
                                      'Redeemed on: ${formatDateWithRelative(redeemedAt)}'),
                                  trailing: Text(
                                    '- ₹$price',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
