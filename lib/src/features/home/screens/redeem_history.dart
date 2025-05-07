import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nearbycreds/src/features/business_dashboard/functins.dart';

class RedeemHistoryPage extends StatefulWidget {
  const RedeemHistoryPage({super.key});

  @override
  _RedeemHistoryPageState createState() => _RedeemHistoryPageState();
}

class _RedeemHistoryPageState extends State<RedeemHistoryPage> with TickerProviderStateMixin {
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

    // Slide animation from the top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start from top
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
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fetch redemption data from the 'redeem' collection
  Stream<QuerySnapshot> _getRedeemedShops() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('redeem')
        .where('userId', isEqualTo: uid) // Fetch only the current user's redemptions
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redeem History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getRedeemedShops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No redemptions found.'));
          }

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
                      final data = docs[index].data() as Map<String, dynamic>;
                      final product = data['product'] ?? {};
                      final productName = product['name'] ?? 'Unknown';
                      final price = (product['price'] ?? 0).toString();
                      final redeemedAt = (data['redeemedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.redeem),
                            title: Text(productName),
                            subtitle: Text('Redeemed on: ${formatDateWithRelative(redeemedAt)}'),
                            trailing: Text(
                              '- ₹$price',
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
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
    );
  }
}
