import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/screens/login_screen.dart';
import 'package:dental_app/screens/tratment_tracking_screen.dart';
import 'package:dental_app/widgets/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_patient.dart';
import 'view_patient_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isDrawerOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF23649E)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF23649E)),
              onPressed: toggleDrawer,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF23649E),
                  Color(0xFF1565C0),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Profile Header Card
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Avatar
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF23649E), Color(0xFF1565C0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF23649E).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // User Name
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text(
                                    "Welcome",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF23649E),
                                    ),
                                  );
                                }

                                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                                final name = userData?["name"] ?? "Guest";

                                return Text(
                                  "Dr. $name",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF23649E),
                                    letterSpacing: -0.5,
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF23649E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Dental Professional",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF23649E),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF23649E).withOpacity(0.1),
                                ),
                              ),
                              child: const Text(
                                "\"Excellence in dental care through precision, compassion, and innovation. Every smile tells a story.\"",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Action Buttons
                      _buildActionButton(
                        title: "Patient Management",
                        subtitle: "View and manage your patients",
                        icon: Icons.people_rounded,
                        color: const Color(0xFF23649E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PatientListScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildActionButton(
                        title: "Profile Settings",
                        subtitle: "Update your professional profile",
                        icon: Icons.settings_rounded,
                        color: const Color(0xFF1565C0),
                        onTap: () {
                          // TODO: Navigate to profile settings
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile settings coming soon!"),
                              backgroundColor: Color(0xFF23649E),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildActionButton(
                        title: "Analytics & Reports",
                        subtitle: "View practice statistics",
                        icon: Icons.analytics_rounded,
                        color: const Color(0xFF0D47A1),
                        onTap: () {
                          // TODO: Navigate to analytics
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Analytics feature coming soon!"),
                              backgroundColor: Color(0xFF23649E),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Custom Drawer
          CustomDrawer(
            isDrawerOpen: _isDrawerOpen,
            toggleDrawer: toggleDrawer,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Treatment model for history entries
class Treatment {
  final DateTime date;
  final String type;
  final double cost;
  final int estimatedSessions;
  final int remainingSessions;

  const Treatment({
    required this.date,
    required this.type,
    required this.cost,
    required this.estimatedSessions,
    required this.remainingSessions,
  });

  Treatment copyWith({
    DateTime? date,
    String? type,
    double? cost,
    int? estimatedSessions,
    int? remainingSessions,
  }) {
    return Treatment(
      date: date ?? this.date,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      estimatedSessions: estimatedSessions ?? this.estimatedSessions,
      remainingSessions: remainingSessions ?? this.remainingSessions,
    );
  }
}

// Patient model with copyWith for easy edits.
class Patient {
  final String id;
  final String name;
  final int age;
  final String phone;
  final String dob;
  final String address;
  final String status; // e.g., "Active", "Follow-up", "Completed"
  final DateTime lastVisit;
  final String allergies;
  final String ongoing;
  final List<Treatment> treatments;
  final String notes;
  final List<String> reportFiles;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.phone,
    required this.dob,
    required this.address,
    required this.status,
    required this.lastVisit,
    required this.allergies,
    required this.ongoing,
    required this.treatments,
    required this.notes,
    required this.reportFiles,
  });

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? phone,
    String? dob,
    String? address,
    String? status,
    DateTime? lastVisit,
    String? allergies,
    String? ongoing,
    List<Treatment>? treatments,
    String? notes,
    List<String>? reportFiles,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      status: status ?? this.status,
      lastVisit: lastVisit ?? this.lastVisit,
      allergies: allergies ?? this.allergies,
      ongoing: ongoing ?? this.ongoing,
      treatments: treatments ?? this.treatments,
      notes: notes ?? this.notes,
      reportFiles: reportFiles ?? this.reportFiles,
    );
  }
}

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen>
    with TickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _addPatient() async {
    final newPatient = await Navigator.push<Patient?>(
      context,
      MaterialPageRoute(builder: (_) => const AddPatientScreen()),
    );

    if (newPatient != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TreatmentTrackingScreen(patient: newPatient),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'follow-up':
        return Colors.orange;
      case 'completed':
        return const Color(0xFF23649E);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Text(
            "⚠️ Please login to view patients",
            style: TextStyle(fontSize: 18, color: Color(0xFF23649E)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Patient Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF23649E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("patients")
              .orderBy("updatedAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "❌ Error loading patients",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF23649E)),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF23649E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.people_outline_rounded,
                        size: 60,
                        color: Color(0xFF23649E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "No Patients Yet",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23649E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Start building your patient database",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                final p = Patient(
                  id: data['id'],
                  name: data['name'],
                  age: data['age'],
                  phone: data['phone'],
                  dob: data['dob'],
                  address: data['address'],
                  status: data['status'] ?? 'Active',
                  lastVisit: (data['lastVisit'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  allergies: data['allergies'] ?? '',
                  ongoing: data['ongoing'] ?? '',
                  treatments: const [],
                  notes: data['notes'] ?? '',
                  reportFiles: List<String>.from(data['reportFiles'] ?? []),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final updatedPatient = await Navigator.push<Patient?>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewPatientScreen(patient: p),
                          ),
                        );
                        if (updatedPatient != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Patient updated successfully"),
                              backgroundColor: Color(0xFF23649E),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Patient Avatar
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF23649E), Color(0xFF1565C0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF23649E).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : "?",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Patient Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Age: ${p.age} • Last visit: ${_formatDate(p.lastVisit)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(p.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      p.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(p.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Arrow Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF23649E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF23649E),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF23649E).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _addPatient,
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: const Text(
            "Add Patient",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF23649E),
          elevation: 0,
        ),
      ),
    );
  }
}