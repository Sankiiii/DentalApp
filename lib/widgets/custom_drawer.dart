import 'package:dental_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  final bool isDrawerOpen;
  final Function toggleDrawer;

  const CustomDrawer({
    super.key,
    required this.isDrawerOpen,
    required this.toggleDrawer,
  });

  @override
  Widget build(BuildContext context) {
   return AnimatedPositioned(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  right: isDrawerOpen ? 0 : -260,
  top: 120, // distance from top
  child: Container(
    width: 250,
    height: 800, // 👈 fixed height
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        bottomLeft: Radius.circular(25),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10,
          offset: const Offset(-5, 5),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 👈 space evenly
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      "Dashboard",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    _buildDrawerItem(Icons.notifications, "Notifications", badge: "3"),
    _buildDrawerItem(Icons.history, "Client History"),
    _buildDrawerItem(Icons.calendar_today, "Schedule"),
    _buildDrawerItem(Icons.photo, "Photos"),
    _buildDrawerItem(Icons.receipt_long, "Billing Details"),
    _buildDrawerItem(Icons.settings, "Settings"),
    _buildDrawerItem(
      Icons.logout,
      "Log Out",
      color: Colors.red.shade600,
      isLogout: true,
      context: context,
    ),
  ],
)

    ),
  ),
);

  }

  Widget _buildDrawerItem(IconData icon, String title,
      {String? badge,
      Color color = Colors.blue,
      bool isLogout = false,
      BuildContext? context}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () async {
          if (isLogout) {
            await FirebaseAuth.instance.signOut();
            if (context != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          elevation: 3,
          minimumSize: const Size(double.infinity, 55),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
