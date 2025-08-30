import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:seestyle_firebase/auth/auth.dart';
import 'package:seestyle_firebase/components/drawer.dart';
import 'package:seestyle_firebase/pages/home_page.dart';
import 'package:seestyle_firebase/pages/order_status_page.dart';
import 'package:seestyle_firebase/pages/profile_page.dart';
import 'package:seestyle_firebase/pages/favorites_page.dart';
import 'package:seestyle_firebase/pages/schedule_appointment_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seestyle_firebase/utils/guest_manager.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  int _selectedIndex = 1;
  String _selectedState = 'upcoming';

  bool get isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

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

  void goToHomePage() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomePage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void goToAppointmentPage() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppointmentPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void goToOrderStatusPage() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OrderStatusPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ProfilePage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "My Appointments",
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'upcoming',
                    label: Text('UPCOMING', style: TextStyle(fontSize: 14)),
                  ),
                  ButtonSegment<String>(
                    value: 'completed',
                    label: Text('COMPLETED', style: TextStyle(fontSize: 14)),
                  ),
                  ButtonSegment<String>(
                    value: 'cancelled',
                    label: Text('CANCELLED', style: TextStyle(fontSize: 14)),
                  ),
                ],
                selected: <String>{_selectedState},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedState = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    return states.contains(WidgetState.selected)
                        ? Colors.white
                        : const Color.fromARGB(255, 40, 44, 52);
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    return states.contains(WidgetState.selected)
                        ? Colors.black
                        : Colors.white;
                  }),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.grey),
                  ),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),



          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .where('state', isEqualTo: _selectedState)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No appointments found for this state.",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                final appointments = snapshot.data!.docs;
return ListView.builder(
  itemCount: appointments.length,
  itemBuilder: (context, index) {
    final appointment = appointments[index];
    final name = appointment['name'];
    final scheduledAt = (appointment['scheduledAt'] as Timestamp).toDate();
    final status = appointment['status'] ?? 'pending';

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'rescheduled':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = Colors.blueGrey;
    }

    final data = appointment.data() as Map<String, dynamic>? ?? {};
    final cancellationReason = data.containsKey('cancellationReason') ? data['cancellationReason'] : null;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${DateFormat('MMM dd, yyyy – hh:mm a').format(scheduledAt)}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${status[0].toUpperCase()}${status.substring(1)}',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (cancellationReason != null && cancellationReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Cancellation Reason: $cancellationReason',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScheduleAppointmentPage()),
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
