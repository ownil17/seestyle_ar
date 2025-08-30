import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seestyle_firebase/admin_dashboard/add_product_page.dart';
import 'package:seestyle_firebase/admin_dashboard/dashboard_components/dash_drawer.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_appointments_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_orders_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_users_page.dart';
import 'package:seestyle_firebase/admin_dashboard/admin_dashboard.dart';
import 'package:seestyle_firebase/auth/auth.dart';
// ✅ Add this line

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const AdminDashboardPage(selectedIndex: 0);
        break;
      case 1:
        destination = const ManageProductsPage();
        break;
      case 2:
        destination = const ManageAppointmentsPage();
        break;
      case 3:
        destination = const ManageOrdersPage();
        break;
      case 4:
        destination = const ManageUsersPage();
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
    final productRef = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
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
          "Manage Products",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      drawer: DashDrawer(
        onTap: () {},
        onManageProductsTap: () {},
        onManageAppointmentsTap: () {},
        onManageOrdersTap: () {},
        onManageUsersTap: () {},
        onSignOut: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        },
      ),// ✅ Add this line
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart, size: 30), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory, size: 30), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today, size: 30), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart, size: 30), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.people, size: 30), label: "Accounts"),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products added yet.', style: TextStyle(color: Colors.white70)),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              final name = product['name'] ?? 'Unnamed';
              final price = product['price'] ?? 0;
              final imageUrl = product['imageUrl'] ?? '';

return Container(
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
            height: 120, // Reduced height slightly
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
      const Spacer(), // Pushes price and button to the bottom
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
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await product.reference.delete();
              },
              iconSize: 20,
              constraints: const BoxConstraints(), // Prevent overflow
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
    ],
  ),
);

            },
          );
        },
      ),
    );
  }
}
