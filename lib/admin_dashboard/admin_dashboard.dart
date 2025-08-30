import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_appointments_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_orders_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_products_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_users_page.dart';
import 'package:seestyle_firebase/admin_dashboard/dashboard_components/dash_drawer.dart';
import 'package:seestyle_firebase/auth/auth.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardPage(selectedIndex: 0);
  }
}

class AdminDashboardPage extends StatefulWidget {
  final int selectedIndex;

  const AdminDashboardPage({super.key, required this.selectedIndex});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late int _selectedIndex;
  List<Map<String, dynamic>> _todayAppointments = [];
  bool _loadingAppointments = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _fetchTodaysAppointments();
  }

  Future<void> _fetchTodaysAppointments() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledAt')
        .get();

    final List<Map<String, dynamic>> appointments = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      _todayAppointments = appointments;
      _loadingAppointments = false;
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loadingAppointments
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const Icon(Icons.today, size: 40, color: Colors.blueGrey),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _todayAppointments.isNotEmpty
                                  ? "You have ${_todayAppointments.length} appointment(s) today."
                                  : "No appointments scheduled for today.",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _todayAppointments.isEmpty
                        ? const Center(
                            child: Text("No appointment details to show.",
                                style: TextStyle(color: Colors.white70, fontSize: 16)),
                          )
                        : ListView.builder(
                            itemCount: _todayAppointments.length,
                            itemBuilder: (context, index) {
                              final appt = _todayAppointments[index];
                              final name = appt['name'] ?? 'Unknown';
                              final contact = appt['contact'] ?? 'N/A';
                              final time = (appt['scheduledAt'] as Timestamp).toDate();
                              final formattedTime =
                                  "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

                              return Card(
                                color: Colors.white10,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.person, color: Colors.white),
                                  title: Text(name, style: const TextStyle(color: Colors.white)),
                                  subtitle: Text("Contact: $contact\nTime: $formattedTime",
                                      style: const TextStyle(color: Colors.white70)),
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
