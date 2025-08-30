import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seestyle_firebase/pages/appointment_page.dart';
import 'package:seestyle_firebase/pages/favorites_page.dart';
import 'package:seestyle_firebase/pages/home_page.dart';
import 'package:seestyle_firebase/pages/item_details_page.dart';
import 'package:seestyle_firebase/pages/order_status_page.dart';
import 'package:seestyle_firebase/pages/profile_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  List<QueryDocumentSnapshot> searchResults = [];
  Set<String> favoriteProductIds = {};
  late TextEditingController _searchController;
  bool isLoading = false;
  String currentSearch = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    currentSearch = widget.searchQuery;
    _performSearch(currentSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      isLoading = true;
      searchResults = []; // Clear old results
    });

    final lowerQuery = query.toLowerCase().trim();

    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('name_lowercase', isGreaterThanOrEqualTo: lowerQuery)
        .where('name_lowercase', isLessThan: '${lowerQuery}z')
        .get();

    final user = FirebaseAuth.instance.currentUser;
    Set<String> favoriteIds = {};

    if (user != null) {
      final favSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      favoriteIds = favSnapshot.docs.map((doc) => doc.id).toSet();
    }

    setState(() {
      currentSearch = query;
      searchResults = snapshot.docs;
      favoriteProductIds = favoriteIds;
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 40, 44, 52),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Search Results', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    _performSearch(_searchController.text.trim());
                  },
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 55, 60, 70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                _performSearch(value.trim());
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Results for "$currentSearch"',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: searchResults.isEmpty
                        ? const Center(
                            child: Text(
                              'No results found.',
                              style: TextStyle(color: Colors.white60),
                            ),
                          )
                        : GridView.builder(
                            itemCount: searchResults.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              final doc = searchResults[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final productId = doc.id;
                              final name = data['name'];
                              final price = data['price'];
                              final description = data['description'] ?? '';
                              final imageUrl = data['imageUrl'] ?? '';
                              final isFavorite = favoriteProductIds.contains(productId);

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
                onPressed: () async {
                  final favRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('favorites')
                      .doc(productId);

                  if (isFavorite) {
                    await favRef.delete();
                    favoriteProductIds.remove(productId);
                  } else {
                    await favRef.set({
                      'name': name,
                      'price': price,
                      'imageUrl': imageUrl,
                      'description': description,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    favoriteProductIds.add(productId);
                  }

                  setState(() {});
                },
                iconSize: 20,
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

                            },
                          ),
                  ),
          ],
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
