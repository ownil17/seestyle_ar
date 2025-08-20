// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Add this
import 'package:seestyle_firebase/admin_dashboard/admin_dashboard.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_products_page.dart';
import 'package:seestyle_firebase/auth/login_or_register.dart';
import 'package:seestyle_firebase/pages/home_page.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<Widget> _getInitialPage() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginOrRegister();
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Maybe fallback if doc hasn't been created yet
        return const LoginOrRegister();
      }

      final role = doc['role'] as String? ?? '';

      if (role == 'admin') {
        return const AdminDashboard();
      } else {
        return const HomePage();
      }
    } catch (e) {
      debugPrint('Error loading user role: $e');
      return const LoginOrRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        }

        return snapshot.data!;
      },
    );
  }
}


