import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Helper method to build image URL from Pinata
  String _buildImageUrl(String? imageRef) {
    if (imageRef == null || imageRef.isEmpty) return '';
    if (imageRef.startsWith('http')) return imageRef;
    return 'https://gateway.pinata.cloud/ipfs/$imageRef';
  }

  // Profile Avatar Widget for drawer
  Widget _buildDrawerProfileAvatar() {
    final user = FirebaseAuth.instance.currentUser;
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        Map<String, dynamic>? userData;
        String name = "Dr";
        String? profileImageUrl;
        
        if (snapshot.hasData && snapshot.data!.exists) {
          userData = snapshot.data!.data() as Map<String, dynamic>?;
          name = userData?["name"] ?? "Dr";
          profileImageUrl = userData?['profileImageUrl'];
        }

        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: profileImageUrl != null && profileImageUrl.isNotEmpty
                ? Image.network(
                    _buildImageUrl(profileImageUrl),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFF23649E),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFF23649E),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              size: 30,
                              color: Colors.white,
                            ),
                            if (name.isNotEmpty)
                              Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFF23649E),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                        if (name.isNotEmpty)
                          Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      right: isDrawerOpen ? 0 : -300,
      top: 0,
      bottom: 0,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF23649E),
              Color(0xFF1565C0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(-5, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Close Button
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () => toggleDrawer(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Profile Section with Image
                    _buildDrawerProfileAvatar(),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Professional Panel",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu Items
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        Icons.notifications_rounded,
                        "Notifications",
                        badge: "3",
                        context: context,
                      ),
                      
                      _buildDrawerItem(
                        Icons.history_rounded,
                        "Patient History",
                        context: context,
                      ),
                      
                      _buildDrawerItem(
                        Icons.calendar_today_rounded,
                        "Schedule",
                        context: context,
                      ),
                      
                      _buildDrawerItem(
                        Icons.photo_library_rounded,
                        "Photos",
                        context: context,
                      ),
                      
                      _buildDrawerItem(
                        Icons.receipt_long_rounded,
                        "Billing Details",
                        context: context,
                      ),
                      
                      _buildDrawerItem(
                        Icons.analytics_rounded,
                        "Analytics",
                        context: context,
                      ),
                      
                      _buildDrawerItem(
                        Icons.settings_rounded,
                        "Settings",
                        context: context,
                      ),
                      
                      const Spacer(),
                      
                      // Logout Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title, {
    String? badge,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle navigation based on title
            switch (title) {
              case "Notifications":
                _showComingSoonDialog(context, "Notifications");
                break;
              case "Patient History":
                _showComingSoonDialog(context, "Patient History");
                break;
              case "Schedule":
                _showComingSoonDialog(context, "Schedule");
                break;
              case "Photos":
                _showComingSoonDialog(context, "Photo Gallery");
                break;
              case "Billing Details":
                _showComingSoonDialog(context, "Billing System");
                break;
              case "Analytics":
                _showComingSoonDialog(context, "Analytics Dashboard");
                break;
              case "Settings":
                _showComingSoonDialog(context, "Settings");
                break;
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF23649E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  color: Color(0xFF23649E),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Coming Soon",
                  style: TextStyle(
                    fontSize: 20,fontWeight: FontWeight.bold,
                    color: Color(0xFF23649E),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$feature is under development and will be available in the next update.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF23649E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF23649E),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Stay tuned for exciting updates!",
                        style: TextStyle(
                          color: Color(0xFF23649E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF23649E), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Got it!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}