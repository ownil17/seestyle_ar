import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seestyle_firebase/auth/auth.dart';
import 'package:seestyle_firebase/components/drawer.dart';
import 'package:seestyle_firebase/pages/appointment_page.dart';
import 'package:seestyle_firebase/pages/favorites_page.dart';
import 'package:seestyle_firebase/pages/item_details_page.dart';
import 'package:seestyle_firebase/pages/order_status_page.dart';
import 'package:seestyle_firebase/pages/profile_page.dart';
import 'package:seestyle_firebase/pages/search_results_page.dart';
import 'package:seestyle_firebase/utils/guest_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
Future<void> signOut() async {
  try {
    if (!GuestManager.isGuest.value) {
      await FirebaseAuth.instance.signOut();
    }
  } catch (e) {
    debugPrint('Error signing out: $e');
  }
  GuestManager.isGuest.value = false;

  // Instead of pushReplacement here, rely on auth state listener or do this:
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const AuthPage()),
    (route) => false,
  );
}


  bool get isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  void _onItemTapped(int index) {
    final isGuest = GuestManager.isGuest.value;

    if (isGuest && (index == 1 || index == 2 || index == 3)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login required to access this page.")),
      );
      return;
    }

    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget destination;
    switch (index) {
      case 0:
        destination = const HomePage();
        break;
      case 1:
        destination = const AppointmentPage();
        break;
      case 2:
        destination = const OrderStatusPage();
        break;
      case 3:
        destination = const ProfilePage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void goToHomePage() => _onItemTapped(0);
  void goToAppointmentPage() => _onItemTapped(1);
  void goToOrderStatusPage() => _onItemTapped(2);
  void goToProfilePage() => _onItemTapped(3);

  void _triggerSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(searchQuery: query),
        ),
      );
    }
  }

Widget _buildProductCard({
  required bool isFavorite,
  required String name,
  required int price,
  required String imageUrl,
  required String description,
  required String productId,
  required bool isGuest,
  required String userId,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetailsPage(
            itemName: name,
            itemPrice: price,
            imageUrl: imageUrl,
            description: description,
            productId: productId,
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[300],
                ),
                child: imageUrl.isEmpty
                    ? const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "₱$price",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                  onPressed: isGuest
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login required to favorite items."),
                            ),
                          );
                        }
                      : () async {
                          final favRef = FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userId)
                              .collection('favorites')
                              .doc(productId);

                          if (isFavorite) {
                            await favRef.delete();
                          } else {
                            await favRef.set({
                              'name': name,
                              'price': price,
                              'imageUrl': imageUrl,
                              'description': description,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                          }

                          setState(() {});
                        },
                  iconSize: 24,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}




@override
Widget build(BuildContext context) {
  final isGuest = GuestManager.isGuest.value;
  final user = FirebaseAuth.instance.currentUser;
  final userId = user?.uid ?? '';

  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 40, 44, 52),
    drawer: MyDrawer(
      onHomeTap: goToHomePage,
      onProfileTap: goToProfilePage,
      onAppointmentTap: goToAppointmentPage,
      onOrdersTap: goToOrderStatusPage,
      onSignOut: signOut,
      isGuest: isGuest,
    ),
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        "SeeStyle",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite, color: Colors.white),
          onPressed: () {
            if (isGuest) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Login required to access favorites.")),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            }
          },
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No products found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final products = snapshot.data!.docs;

          // Select 4 random featured products (or less if fewer products)
          final randomFeatured = (products.length <= 4)
              ? products
              : (products.toList()..shuffle()).take(4).toList();

          // Calculate height for featured grid:
          const featuredItemHeight = 250.0; // Approx height per grid item
          final featuredRowCount = (randomFeatured.length / 2).ceil();
          // ignore: unused_local_variable
          final featuredGridHeight =
              featuredRowCount * featuredItemHeight + (featuredRowCount - 1) * 10;

          return ListView(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => _triggerSearch(),
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.grey),
                    onPressed: _triggerSearch,
                  ),
                ),
              ),
              const SizedBox(height: 20),

// Featured Frames Title
const Text(
  "Featured Frames",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
const SizedBox(height: 10),

// Featured Frames Grid (updated — no fixed height)
GridView.builder(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.7,
  ),
  itemCount: randomFeatured.length,
  itemBuilder: (context, index) {
    final product = randomFeatured[index];
    final name = product['name'] ?? 'Unnamed';

    final priceRaw = product['price'] ?? 0;
    final price = (priceRaw is double) ? priceRaw.toInt() : priceRaw;

    final imageUrl = product['imageUrl'] ?? '';
    final description = product['description'] ?? '';
    final productId = product.id;

    if (isGuest) {
      return _buildProductCard(
        isFavorite: false,
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
        productId: productId,
        isGuest: isGuest,
        userId: userId,
      );
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('favorites')
            .doc(productId)
            .get(),
        builder: (context, favSnapshot) {
          bool isFavorite = false;

          if (favSnapshot.connectionState == ConnectionState.done) {
            if (favSnapshot.hasData && favSnapshot.data != null) {
              isFavorite = favSnapshot.data!.exists;
            }
          }

          return _buildProductCard(
            isFavorite: isFavorite,
            name: name,
            price: price,
            imageUrl: imageUrl,
            description: description,
            productId: productId,
            isGuest: isGuest,
            userId: userId,
          );
        },
      );
    }
  },
),
const SizedBox(height: 20),

// All Products Title
const Text(
  "All Products",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),
const SizedBox(height: 10),

// All Products Grid (remains the same)
GridView.builder(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.7,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    final name = product['name'] ?? 'Unnamed';

    final priceRaw = product['price'] ?? 0;
    final price = (priceRaw is double) ? priceRaw.toInt() : priceRaw;

    final imageUrl = product['imageUrl'] ?? '';
    final description = product['description'] ?? '';
    final productId = product.id;

    if (isGuest) {
      return _buildProductCard(
        isFavorite: false,
        name: name,
        price: price,
        imageUrl: imageUrl,
        description: description,
        productId: productId,
        isGuest: isGuest,
        userId: userId,
      );
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('favorites')
            .doc(productId)
            .get(),
        builder: (context, favSnapshot) {
          bool isFavorite = false;

          if (favSnapshot.connectionState == ConnectionState.done) {
            if (favSnapshot.hasData && favSnapshot.data != null) {
              isFavorite = favSnapshot.data!.exists;
            }
          }

          return _buildProductCard(
            isFavorite: isFavorite,
            name: name,
            price: price,
            imageUrl: imageUrl,
            description: description,
            productId: productId,
            isGuest: isGuest,
            userId: userId,
          );
        },
      );
    }
  },
),
const SizedBox(height: 20),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 30),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today, size: 30),
          label: "Appointment",
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.glasses, size: 30),
          label: "My Eyeglasses",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30),
          label: "Profile",
        ),
      ],
    ),
  );
}

}
