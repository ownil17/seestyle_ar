import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seestyle_firebase/admin_dashboard/admin_dashboard.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_orders_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_products_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_users_page.dart';
import 'package:seestyle_firebase/admin_dashboard/dashboard_components/dash_drawer.dart';
import 'package:seestyle_firebase/auth/auth.dart';

class ManageAppointmentsPage extends StatefulWidget {
  const ManageAppointmentsPage({super.key});

  @override
  State<ManageAppointmentsPage> createState() => _ManageAppointmentsPageState();
}

class _ManageAppointmentsPageState extends State<ManageAppointmentsPage> {
  final int _selectedIndex = 2;

  final List<String> statusOptions = ['approved', 'cancelled'];
  final List<String> stateOptions = ['upcoming', 'completed'];
  final List<String> showStatusOptions = ['yes', 'no'];

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

  Future<String> _getUsername(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(userId).get();
      return userDoc.data()?['username'] ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<String?> _showCancellationReasonDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancellation Reason'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for cancellation',
          ),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(context).pop(reason);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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
          "Manage Appointments",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .orderBy('scheduledAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data!.docs;

          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                'No appointments scheduled.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final name = appointment['name'];
              final scheduledAt = (appointment['scheduledAt'] as Timestamp).toDate();
              final userId = appointment['userId'];

              return FutureBuilder<String>(
                future: _getUsername(userId),
                builder: (context, userSnapshot) {
                  final username = userSnapshot.data ?? 'Loading...';

                  final data = appointment.data() as Map<String, dynamic>? ?? {};
                  final showStatusValue = (data.containsKey('showStatus') && data['showStatus'] != null)
                      ? data['showStatus'] as String
                      : 'unknown';

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('User: $username'),
                                    const SizedBox(height: 2),
                                    Text('Date: ${scheduledAt.toLocal()}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          IntrinsicHeight(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  const Text("Status: "),
                                  DropdownButton<String>(
                                    value: appointment['status'],
                                    items: statusOptions
                                        .map((status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status[0].toUpperCase() + status.substring(1)),
                                            ))
                                        .toList(),
                                    onChanged: (newStatus) async {
                                      if (newStatus == null) return;

                                      if (newStatus == 'cancelled') {
                                        // Show dialog to get reason
                                        final reason = await _showCancellationReasonDialog(context);
                                        if (reason == null || reason.trim().isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Cancellation reason is required')),
                                          );
                                          return;
                                        }

                                        await FirebaseFirestore.instance
                                            .collection('appointments')
                                            .doc(appointment.id)
                                            .update({
                                          'status': newStatus,
                                          'cancellationReason': reason.trim(),
                                        });
                                      } else {
                                        // Update status and remove cancellation reason if any
                                        await FirebaseFirestore.instance
                                            .collection('appointments')
                                            .doc(appointment.id)
                                            .update({
                                          'status': newStatus,
                                          'cancellationReason': FieldValue.delete(),
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  const Text("State: "),
                                  DropdownButton<String>(
                                    value: appointment['state'],
                                    items: stateOptions
                                        .map((state) => DropdownMenuItem(
                                              value: state,
                                              child: Text(state[0].toUpperCase() + state.substring(1)),
                                            ))
                                        .toList(),
                                    onChanged: (newState) {
                                      if (newState != null) {
                                        FirebaseFirestore.instance
                                            .collection('appointments')
                                            .doc(appointment.id)
                                            .update({'state': newState});
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  const Text("Showed: "),
                                  DropdownButton<String>(
                                    value: showStatusValue,
                                    items: showStatusOptions
                                        .map((value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(value[0].toUpperCase() + value.substring(1)),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        FirebaseFirestore.instance
                                            .collection('appointments')
                                            .doc(appointment.id)
                                            .update({'showStatus': newValue});
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (data.containsKey('cancellationReason') && data['cancellationReason'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Reason: ${data['cancellationReason']}',
                                style: TextStyle(color: Colors.red[700], fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
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
    );
  }
}
