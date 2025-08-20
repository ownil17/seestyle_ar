import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ... (imports remain the same)

class ItemDetailsPage extends StatefulWidget {
  final String itemName;
  final dynamic itemPrice;
  final String? imageUrl;
  final String description;
  final String productId;

  const ItemDetailsPage({
    Key? key,
    required this.itemName,
    required this.itemPrice,
    required this.description,
    required this.productId,
    this.imageUrl,
  }) : super(key: key);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late String userId;
  bool isFavorite = false;
  List<Map<String, dynamic>> recommendedFrames = [];
  Set<String> favoriteFrameIds = {};

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? '';
    _checkFavoriteStatus();
    _fetchRecommendedFrames();
  }

  Future<void> _checkFavoriteStatus() async {
    final favDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.productId)
        .get();

    setState(() {
      isFavorite = favDoc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final favRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('favorites')
        .doc(widget.productId);

    if (isFavorite) {
      await favRef.delete();
    } else {
      await favRef.set({
        'name': widget.itemName,
        'price': widget.itemPrice,
        'imageUrl': widget.imageUrl ?? '',
        'description': widget.description,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> _fetchRecommendedFrames() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    final favSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('favorites')
        .get();

    final favIds = favSnapshot.docs.map((doc) => doc.id).toSet();

    final allFrames = snapshot.docs
        .where((doc) => doc.id != widget.productId)
        .map((doc) => {
              'id': doc.id,
              ...doc.data(),
            })
        .toList();

    allFrames.shuffle(Random());

    if (mounted) {
      setState(() {
        recommendedFrames = allFrames.take(6).toList();
        favoriteFrameIds = favIds;
      });
    }
  }


  Future<void> _toggleRecommendedFavorite(
      String productId, Map<String, dynamic> frameData) async {
    final favRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('favorites')
        .doc(productId);

    if (favoriteFrameIds.contains(productId)) {
      await favRef.delete();
      setState(() {
        favoriteFrameIds.remove(productId);
      });
    } else {
      await favRef.set({
        'name': frameData['name'],
        'price': frameData['price'],
        'imageUrl': frameData['imageUrl'] ?? '',
        'description': frameData['description'] ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        favoriteFrameIds.add(productId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 40, 44, 52),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                    ? const Center(
                        child: Icon(Icons.image, size: 100, color: Colors.grey),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Name and Favorite
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.itemName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Price
            Text(
              "₱${widget.itemPrice.toString()}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70),
            ),

            const SizedBox(height: 30),

            // Description
            Text(
              widget.description,
              style: const TextStyle(color: Colors.white60, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Recommended Frames
            if (recommendedFrames.isNotEmpty) ...[
              const Text(
                "Recommended Frames",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendedFrames.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final frame = recommendedFrames[index];
                  final frameImage = frame['imageUrl'] ?? '';
                  final frameName = frame['name'] ?? 'No name';
                  final framePrice = frame['price'] ?? 0;
                  final frameDesc = frame['description'] ?? '';
                  final frameId = frame['id'];
                  final isFavorite = favoriteFrameIds.contains(frameId);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailsPage(
                            itemName: frameName,
                            itemPrice: framePrice,
                            description: frameDesc,
                            imageUrl: frameImage,
                            productId: frameId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: frameImage.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(frameImage),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: Colors.grey[300],
                                ),
                                child: frameImage.isEmpty
                                    ? const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          // Name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              frameName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Price and Favorite
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₱$framePrice",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.black,
                                  ),
                                  iconSize: 20,
                                  onPressed: () => _toggleRecommendedFavorite(frameId, frame),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

              ),
            ],
          ],
        ),
      ),
    );
  }
}
