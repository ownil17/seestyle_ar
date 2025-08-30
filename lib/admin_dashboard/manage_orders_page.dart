import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seestyle_firebase/admin_dashboard/admin_dashboard.dart';
import 'package:seestyle_firebase/admin_dashboard/dashboard_components/dash_drawer.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_appointments_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_products_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_users_page.dart';
import 'package:seestyle_firebase/auth/auth.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
  final ordersRef = FirebaseFirestore.instance.collection('orders');
  final int _selectedIndex = 3;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

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

  void _addOrder() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('role', isNotEqualTo: 'admin')
        .get();

    if (usersSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No non-admin users found in Firestore.")),
      );
      return;
    }

    String? selectedUserId = usersSnapshot.docs.first.id;
    bool userHasOrder = false;

    final prescriptionDateController = TextEditingController();
    final frameModelController = TextEditingController();
    final lensTypeController = TextEditingController();
    final estimatedReadyDateController = TextEditingController();

    final odSphereController = TextEditingController();
    final odCylinderController = TextEditingController();
    final odAxisController = TextEditingController();
    final odPrismController = TextEditingController();
    final odAddController = TextEditingController();
    final osSphereController = TextEditingController();
    final osCylinderController = TextEditingController();
    final osAxisController = TextEditingController();
    final osPrismController = TextEditingController();
    final osAddController = TextEditingController();

    Future<bool> checkUserOrder(String userId) async {
      final ordersQuery = await ordersRef.where('userId', isEqualTo: userId).get();
      return ordersQuery.docs.isNotEmpty;
    }

    userHasOrder = await checkUserOrder(selectedUserId);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Create New Order'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedUserId,
                    items: usersSnapshot.docs.map((userDoc) {
                      final username = userDoc.data().containsKey('username')
                          ? userDoc['username']
                          : 'Unknown';
                      return DropdownMenuItem(
                        value: userDoc.id,
                        child: Text(username),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      if (val == null) return;
                      setState(() {
                        selectedUserId = val;
                        userHasOrder = false;
                      });
                      userHasOrder = await checkUserOrder(val);
                      setState(() {});
                    },
                    decoration: const InputDecoration(labelText: "Select User"),
                  ),
                  if (userHasOrder)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'This user already has an existing order.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text("Glasses Information",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  // Removed Customer Name input field here
                  TextFormField(
                    controller: prescriptionDateController,
                    decoration: const InputDecoration(labelText: "Prescription Date"),
                  ),
                  TextFormField(
                    controller: frameModelController,
                    decoration: const InputDecoration(labelText: "Frame Model"),
                  ),
                  TextFormField(
                    controller: lensTypeController,
                    decoration: const InputDecoration(labelText: "Lens Type"),
                  ),
                  TextFormField(
                    controller: estimatedReadyDateController,
                    decoration: const InputDecoration(labelText: "Estimated Ready Date"),
                  ),
                  const SizedBox(height: 20),
                  const Text("Prescription (OD = Right, OS = Left)",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                      5: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Colors.grey),
                        children: const [
                          Padding(padding: EdgeInsets.all(8), child: Text("")),
                          Padding(padding: EdgeInsets.all(8), child: Text("Sphere")),
                          Padding(padding: EdgeInsets.all(8), child: Text("Cylinder")),
                          Padding(padding: EdgeInsets.all(8), child: Text("Axis")),
                          Padding(padding: EdgeInsets.all(8), child: Text("Prism")),
                          Padding(padding: EdgeInsets.all(8), child: Text("Add")),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(padding: EdgeInsets.all(8), child: Text("OD")),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: odSphereController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: odCylinderController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: odAxisController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: odPrismController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: odAddController)),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(padding: EdgeInsets.all(8), child: Text("OS")),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: osSphereController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: osCylinderController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: osAxisController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: osPrismController)),
                          Padding(padding: const EdgeInsets.all(4), child: TextField(controller: osAddController)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: userHasOrder
                      ? null
                      : () async {
                          if (selectedUserId != null) {
                            final selectedUserDoc = usersSnapshot.docs
                                .firstWhere((doc) => doc.id == selectedUserId);

                            await ordersRef.add({
                              'userId': selectedUserId,
                              'full_name': selectedUserDoc['full_name'],  // copy full_name here
                              'email': selectedUserDoc['email'],
                              'status': 0,
                              'createdAt': FieldValue.serverTimestamp(),
                              // 'customerName': customerNameController.text, // removed
                              'prescriptionDate': prescriptionDateController.text,
                              'frameModel': frameModelController.text,
                              'lensType': lensTypeController.text,
                              'estimatedReadyDate': estimatedReadyDateController.text,
                              'prescription': {
                                'OD': {
                                  'sphere': odSphereController.text,
                                  'cylinder': odCylinderController.text,
                                  'axis': odAxisController.text,
                                  'prism': odPrismController.text,
                                  'add': odAddController.text,
                                },
                                'OS': {
                                  'sphere': osSphereController.text,
                                  'cylinder': osCylinderController.text,
                                  'axis': osAxisController.text,
                                  'prism': osPrismController.text,
                                  'add': osAddController.text,
                                },
                              },
                            });

                            Navigator.pop(context);
                          }
                        },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  

void _showEditOrderDialog(DocumentSnapshot orderDoc) {
  final od = orderDoc['prescription']['OD'] as Map<String, dynamic>;
  final os = orderDoc['prescription']['OS'] as Map<String, dynamic>;

  final odSphereController = TextEditingController(text: od['sphere']);
  final odCylinderController = TextEditingController(text: od['cylinder']);
  final odAxisController = TextEditingController(text: od['axis']);
  final odPrismController = TextEditingController(text: od['prism']);
  final odAddController = TextEditingController(text: od['add']);

  final osSphereController = TextEditingController(text: os['sphere']);
  final osCylinderController = TextEditingController(text: os['cylinder']);
  final osAxisController = TextEditingController(text: os['axis']);
  final osPrismController = TextEditingController(text: os['prism']);
  final osAddController = TextEditingController(text: os['add']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        scrollable: true,
        title: const Text("Edit Prescription"),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("OD (Right Eye)", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: odSphereController, decoration: const InputDecoration(labelText: 'Sphere')),
                  TextField(controller: odCylinderController, decoration: const InputDecoration(labelText: 'Cylinder')),
                  TextField(controller: odAxisController, decoration: const InputDecoration(labelText: 'Axis')),
                  TextField(controller: odPrismController, decoration: const InputDecoration(labelText: 'Prism')),
                  TextField(controller: odAddController, decoration: const InputDecoration(labelText: 'Add')),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("OS (Left Eye)", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: osSphereController, decoration: const InputDecoration(labelText: 'Sphere')),
                  TextField(controller: osCylinderController, decoration: const InputDecoration(labelText: 'Cylinder')),
                  TextField(controller: osAxisController, decoration: const InputDecoration(labelText: 'Axis')),
                  TextField(controller: osPrismController, decoration: const InputDecoration(labelText: 'Prism')),
                  TextField(controller: osAddController, decoration: const InputDecoration(labelText: 'Add')),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await orderDoc.reference.update({
                'prescription.OD': {
                  'sphere': odSphereController.text,
                  'cylinder': odCylinderController.text,
                  'axis': odAxisController.text,
                  'prism': odPrismController.text,
                  'add': odAddController.text,
                },
                'prescription.OS': {
                  'sphere': osSphereController.text,
                  'cylinder': osCylinderController.text,
                  'axis': osAxisController.text,
                  'prism': osPrismController.text,
                  'add': osAddController.text,
                },
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}




  void _updateOrderStatus(DocumentSnapshot orderDoc, int newStatus) async {
    await orderDoc.reference.update({'status': newStatus});
  }

  String _statusText(int step) {
    switch (step) {
      case 0:
        return 'Prescription Issued';
      case 1:
        return 'Lenses in Progress';
      case 2:
        return 'Quality Check';
      case 3:
        return 'Ready for Pickup';
      default:
        return 'Unknown';
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
        title: const Text(
          "Manage Orders",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _addOrder,
          ),
        ],
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
        stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders available.', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final status = order['status'] ?? 0;

return Card(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  color: Colors.grey[200],
  margin: const EdgeInsets.only(bottom: 16),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${order['full_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Email: ${order['email']}'),
        const SizedBox(height: 12),

        Row(
          children: [
            const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: status,
              onChanged: (value) {
                if (value != null) {
                  _updateOrderStatus(order, value);
                }
              },
              items: List.generate(4, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(_statusText(i)),
                );
              }),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                // You can navigate to a detail/edit screen or show a dialog
                // Example:
                _showEditOrderDialog(order);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

const SizedBox(height: 8),
const Text("Prescription", style: TextStyle(fontWeight: FontWeight.bold)),
const SizedBox(height: 8),
Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("OD (Right Eye)", style: TextStyle(decoration: TextDecoration.underline)),
          Text('Sphere: ${order['prescription']['OD']['sphere']}'),
          Text('Cylinder: ${order['prescription']['OD']['cylinder']}'),
          Text('Axis: ${order['prescription']['OD']['axis']}'),
          Text('Prism: ${order['prescription']['OD']['prism']}'),
          Text('Add: ${order['prescription']['OD']['add']}'),
        ],
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("OS (Left Eye)", style: TextStyle(decoration: TextDecoration.underline)),
          Text('Sphere: ${order['prescription']['OS']['sphere']}'),
          Text('Cylinder: ${order['prescription']['OS']['cylinder']}'),
          Text('Axis: ${order['prescription']['OS']['axis']}'),
          Text('Prism: ${order['prescription']['OS']['prism']}'),
          Text('Add: ${order['prescription']['OS']['add']}'),
        ],
      ),
    ),
  ],
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
