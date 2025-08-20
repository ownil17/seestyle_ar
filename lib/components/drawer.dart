import 'package:flutter/material.dart';
import 'package:seestyle_firebase/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onHomeTap;
  final void Function()? onProfileTap;
  final void Function()? onAppointmentTap;
  final void Function()? onOrdersTap;
  final void Function()? onSignOut;
  final bool isGuest;  // <-- add this

  const MyDrawer({
    super.key,
    required this.onHomeTap,
    required this.onProfileTap,
    required this.onAppointmentTap,
    required this.onOrdersTap,
    required this.onSignOut,
    required this.isGuest,  // <-- add this
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 40, 44, 52),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            // header
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: const Color.fromARGB(255, 40, 44, 52),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 75,
                ),
              ),
            ),

            // home list tile
            MyListTile(
              icon: Icons.home,
              text: 'H O M E',
              onTap: onHomeTap,
            ),

            // appointment list tile
            MyListTile(
              icon: Icons.calendar_today,
              text: 'A P P O I N T M E N T',
              onTap: onAppointmentTap,
            ),

            // eyeglasses list tile
            MyListTile(
              icon: Icons.assignment,
              text: 'E Y E G L A S S E S',
              onTap: onOrdersTap,
            ),

            // profile list tile
            MyListTile(
              icon: Icons.person,
              text: 'P R O F I L E',
              onTap: onProfileTap,
            ),
          ]),
          // logout/sign in list tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout,
              text: isGuest ? 'S I G N  I N' : 'L O G O U T',  // change label based on guest
              onTap: onSignOut,
            ),
          ),
        ],
      ),
    );
  }
}
