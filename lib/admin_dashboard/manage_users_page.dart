import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seestyle_firebase/admin_dashboard/admin_dashboard.dart';
import 'package:seestyle_firebase/admin_dashboard/dashboard_components/dash_drawer.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_appointments_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_orders_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_products_page.dart';
import 'package:seestyle_firebase/auth/auth.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({Key? key}) : super(key: key);

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final usersRef = FirebaseFirestore.instance.collection('Users');
  int _selectedIndex = 4;
  String _searchQuery = '';

  final Map<int, Widget> _pages = {
    0: AdminDashboard(),
    1: ManageProductsPage(),
    2: ManageAppointmentsPage(),
    3: ManageOrdersPage(),
    4: ManageUsersPage(),
  };

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _pages[index]!,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _confirmDeleteUser(
      BuildContext context, DocumentSnapshot userDoc, String username) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "$username"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await userDoc.reference.delete();
    }
  }

  Future<void> _editUser(BuildContext context, DocumentSnapshot userDoc) async {
    final data = userDoc.data() as Map<String, dynamic>? ?? {};

    final usernameController = TextEditingController(text: data['username'] ?? '');
    final ageController = TextEditingController(text: (data['age'] ?? '').toString());
    final contactController = TextEditingController(text: data['contact'] ?? '');
    String selectedRole = data['role'] ?? 'user';

    final List<String> roles = ['user', 'admin', 'staff']; // Adjust roles here

    final _formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Edit Basic Info'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Username required' : null,
                ),

                const SizedBox(height: 16),

                // Role dropdown
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: roles
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role[0].toUpperCase() + role.substring(1)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Role required' : null,
                ),

                const SizedBox(height: 16),

                // Age
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final numVal = int.tryParse(value);
                    if (numVal == null || numVal < 0) {
                      return 'Enter valid age';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Contact
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                // Update user doc
                await userDoc.reference.update({
                  'username': usernameController.text.trim(),
                  'role': selectedRole,
                  'age': ageController.text.trim().isEmpty
                      ? null
                      : int.parse(ageController.text.trim()),
                  'contact': contactController.text.trim(),
                });
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Admin Dashboard",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      drawer: DashDrawer(
        onTap: () {},
        onManageProductsTap: () {
          _onItemTapped(1);
        },
        onManageAppointmentsTap: () {
          _onItemTapped(2);
        },
        onManageOrdersTap: () {
          _onItemTapped(3);
        },
        onManageUsersTap: () {
          _onItemTapped(4);
        },
        onSignOut: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        },
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by username or email',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // User list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.orderBy('username').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No users found.', style: TextStyle(color: Colors.white70)),
                  );
                }

                final users = snapshot.data!.docs.where((user) {
                  final username = (user['username'] ?? '').toString().toLowerCase();
                  final email = (user['email'] ?? '').toString().toLowerCase();
                  return username.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users match your search.', style: TextStyle(color: Colors.white70)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final username = user['username'] ?? 'Unknown';
                    final email = user['email'] ?? 'No Email';
                    final role = user['role'] ?? 'N/A';
                    final age = user['age']?.toString() ?? '';
                    final contact = user['contact'] ?? '';

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.grey[200],
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: $email'),
                            Text('Role: $role'),
                            if (age.isNotEmpty) Text('Age: $age'),
                            if (contact.isNotEmpty) Text('Contact: $contact'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteUser(context, user, username),
                        ),
                        onTap: () => _editUser(context, user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
    );
  }
}
