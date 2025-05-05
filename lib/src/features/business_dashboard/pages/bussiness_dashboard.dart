import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearbycreds/src/features/business_dashboard/functins.dart';

class BussinessDashboard extends StatefulWidget {
  const BussinessDashboard({super.key});

  @override
  State<BussinessDashboard> createState() => _BussinessDashboardState();
}

class _BussinessDashboardState extends State<BussinessDashboard> {
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<void> _deleteShop(String shopId) async {
    try {
      await FirebaseFirestore.instance.collection('shops').doc(shopId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting shop: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shops'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shops')
            .where('ownerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No shops found.'));
          }

          final shops = snapshot.data!.docs;

          return ListView.builder(
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              final name = shop['name'];
              final active = shop['active'];
              final shopId = shop.id;
              final data = shop.data() as Map<String, dynamic>;
              final imageUrl = data['product']['imageUrl'] as String? ?? '';
              const fallbackImageUrl = 'https://media.gettyimages.com/id/1437990851/photo/handsome-asian-male-searching-for-groceries-from-the-list-on-his-mobile-phone.jpg?s=612x612&w=gi&k=20&c=9wLzG-h9NP35vtiYPEwaiu0XhJEe7uE3aoiX4DFW-xc=';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Use CachedNetworkImage with fallback for invalid URL
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl.isNotEmpty ? imageUrl : fallbackImageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Image.network(fallbackImageUrl, fit: BoxFit.cover),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  active ? Icons.check_circle : Icons.cancel,
                                  color: active
                                      ? const Color.fromARGB(255, 11, 116, 14)
                                      : const Color.fromARGB(255, 179, 12, 0),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(active ? 'Active' : 'Inactive'),
                              ],
                            ),
                            Text(shop['product']['name'] ?? 'No name',style: const TextStyle(fontWeight: FontWeight.bold),),
                            Text('₹ ${shop['product']['price'] ?? '0.0'}', style: const TextStyle(fontWeight: FontWeight.bold,color:   Color.fromARGB(255, 11, 116, 14))),

                            Text(shop['product']['description'] ?? 'No description'),
                            Text(
                              shop['createdAt'] != null
                                  ? "Posted on: ${formatDateWithRelative((shop['createdAt'] as Timestamp).toDate())}"
                                  : "Posted on: Unknown",
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                context.push('/add-edit-shop', extra: {
                                  'shopId': shopId,
                                  'name': shop['name'],
                                  'active': shop['active'],
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 179, 12, 0)),
                              onPressed: () async {
                                bool? confirmDelete = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Shop'),
                                    content: const Text('Are you sure you want to delete this shop?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmDelete == true) {
                                  await _deleteShop(shopId);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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
