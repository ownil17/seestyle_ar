import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seestyle_firebase/auth/auth.dart';
import 'package:seestyle_firebase/components/drawer.dart';
import 'package:seestyle_firebase/components/glasses_info_card.dart';
import 'package:seestyle_firebase/components/glasses_timeline.dart';
import 'package:seestyle_firebase/pages/home_page.dart';
import 'package:seestyle_firebase/pages/appointment_page.dart';
import 'package:seestyle_firebase/pages/profile_page.dart';
import 'package:seestyle_firebase/pages/favorites_page.dart';
import 'package:seestyle_firebase/utils/guest_manager.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({Key? key}) : super(key: key);

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

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

  Future<DocumentSnapshot?> _fetchLatestOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final query = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return query.docs.first;
    } catch (e) {
      print('❌ Error fetching order: $e');
      return null;
    }
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

  Future<void> signOut() async {
    try {
      if (!GuestManager.isGuest.value) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
    GuestManager.isGuest.value = false;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  bool get isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

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
          "My Eyeglasses",
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
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot?>(
          future: _fetchLatestOrder(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'No prescription glasses ordered.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final orderSnapshot = snapshot.data!;
            final dataMap = orderSnapshot.data() as Map<String, dynamic>?;

            if (dataMap == null || dataMap['prescription'] == null || dataMap['prescription'].isEmpty) {
              return const Center(
                child: Text(
                  'No prescription glasses ordered.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final currentStep = dataMap['status'] ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassesTimeline(currentStep: currentStep),
                  GlassesInfoCard(
                    customerName: dataMap['customerName'] ?? 'N/A',
                    prescriptionDate: dataMap['prescriptionDate'] ?? 'N/A',
                    frameModel: dataMap['frameModel'] ?? 'N/A',
                    lensType: dataMap['lensType'] ?? 'N/A',
                    estimatedReadyDate: dataMap['estimatedReadyDate'] ?? 'N/A',
                    prescription: dataMap['prescription'],
                  ),
                ],
              ),
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
