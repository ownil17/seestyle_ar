import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seestyle_firebase/auth/auth.dart';
import 'package:seestyle_firebase/components/text_box.dart';
import 'package:seestyle_firebase/components/drawer.dart';
import 'package:seestyle_firebase/pages/appointment_page.dart';
import 'package:seestyle_firebase/pages/favorites_page.dart';
import 'package:seestyle_firebase/pages/home_page.dart';
import 'package:seestyle_firebase/pages/order_status_page.dart';
import 'package:seestyle_firebase/utils/guest_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  int _selectedIndex = 3;

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

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              "Edit $field",
              style: const TextStyle(color: Colors.white),
            ),
            content: TextField(
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter new $field",
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              onChanged: (value) => newValue = value,
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(newValue),
              ),
            ],
          ),
    );

    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
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
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: const Text(
          "Profile",
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
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

return ListView(
  children: [
    const SizedBox(height: 50),
    const Icon(Icons.person, size: 72, color: Colors.white),
    const SizedBox(height: 10),
    Text(
      currentUser.email!,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[300]),
    ),
    const SizedBox(height: 50),
    Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: Text(
        'My Details',
        style: TextStyle(color: Colors.grey[400]),
      ),
    ),
    MyTextBox(
      text: userData['full_name'],
      sectionName: 'Full Name',
      onPressed: () => editField('full_name'),
    ),
    MyTextBox(
      text: userData['username'],
      sectionName: 'Username',
      onPressed: () => editField('username'),
    ),
    MyTextBox(
      text: userData['age'],
      sectionName: 'Age',
      onPressed: () => editField('age'),
    ),
    MyTextBox(
      text: userData['birthday'],
      sectionName: 'Birthday',
      onPressed: () => editField('birthday'),
    ),
    MyTextBox(
      text: userData['contact'],
      sectionName: 'Contact No.',
      onPressed: () => editField('contact'),
    ),
  ],
);

          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
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
