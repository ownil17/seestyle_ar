// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:seestyle_firebase/admin_dashboard/admin_dashboard.dart';
import 'package:seestyle_firebase/admin_dashboard/dashboard_components/dash_list_tile.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_appointments_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_orders_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_products_page.dart';
import 'package:seestyle_firebase/admin_dashboard/manage_users_page.dart';

class DashDrawer extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? onManageProductsTap;
  final void Function()? onManageAppointmentsTap;
  final void Function()? onManageOrdersTap;
  final void Function()? onManageUsersTap;
  final void Function()? onSignOut;

  const DashDrawer({
    super.key,
    required this.onTap,
    required this.onManageProductsTap,
    required this.onManageAppointmentsTap,
    required this.onManageOrdersTap,
    required this.onManageUsersTap,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Header
              SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: const Color.fromARGB(255, 40, 44, 52),
                  child: const Text(
                    'M E N U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Dashboard
              DashListTile(
                icon: Icons.insert_chart,
                text: 'D A S H B O A R D',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminDashboard()),
                  );
                },
              ),

              // Products
              DashListTile(
                icon: Icons.local_offer,
                text: 'P R O D U C T S',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageProductsPage()),
                  );
                },
              ),

              // Appointments
              DashListTile(
                icon: Icons.calendar_today,
                text: 'A P P O I N T M E N T S',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageAppointmentsPage()),
                  );
                },
              ),

              // Orders (Eyeglasses)
              DashListTile(
                icon: FontAwesomeIcons.shoppingCart,
                text: 'O R D E R S',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageOrdersPage()),
                  );
                },
              ),

              // Users
              DashListTile(
                icon: Icons.people,
                text: 'U S E R S',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageUsersPage()),
                  );
                },
              ),
            ],
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: DashListTile(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
