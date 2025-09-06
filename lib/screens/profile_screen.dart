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

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: toggleDrawer,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Profile Content
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Color(0xFFE0F7FA), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 55,
                    // backgroundImage: AssetImage("assets/images/profile_img.png"),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),

                  // User name from Firestore
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text(
                          "Guest",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      }

                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      final name = userData?["name"] ?? "Guest";

                      return Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "Just like fingerprints, toothprints are unique to each individual.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ✅ Fixed Button (No nested ElevatedButton)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PatientListScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Colors.blue.shade200,
                      ),
                      child: const Text(
                        "View Patient List",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  _buildMainButton("View your profile"),
                ],
              ),
            ),
          ),
          // Custom Drawer (Reusable)
          CustomDrawer(
            isDrawerOpen: _isDrawerOpen,
            toggleDrawer: toggleDrawer,
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // TODO: add action for "View your profile"
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6,
          shadowColor: Colors.blue.shade200,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}





/// Treatment model for history entries
/// Treatment model for history entries
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



/// Patient model with copyWith for easy edits.
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

class _PatientListScreenState extends State<PatientListScreen> {
  /// In-memory list. Replace with DB/API later as needed.
  final List<Patient> _patients = [
  Patient(
    id: 'P001',
    name: 'Sanket Angane',
    age: 20,
    phone: '932186XXXX',
    dob: '01/07/2005',
    address: 'Tambe Nagar, Mulund.',
    status: 'Active',
    lastVisit: DateTime.now().subtract(const Duration(days: 10)),
    allergies: 'Penicillin',
    ongoing: 'Diabetes',
    treatments: [
      Treatment(
        date: DateTime(2025, 7, 1),
        type: 'Root Canal',
        cost: 500,
        estimatedSessions: 3,
        remainingSessions: 2,
      ),
      Treatment(
        date: DateTime(2025, 9, 11),
        type: 'Filling',
        cost: 700,
        estimatedSessions: 1,
        remainingSessions: 1,
      ),
    ],
    notes: 'Patient reports pain in the lower right tooth',
    reportFiles: ['assets/images/xray.jpg', 'assets/images/xray.jpg'],
  ),
  Patient(
    id: 'P002',
    name: 'Rohan Patil',
    age: 34,
    phone: '9988776655',
    dob: '12/02/1991',
    address: 'Dadar East, Mumbai.',
    status: 'Follow-up',
    lastVisit: DateTime.now().subtract(const Duration(days: 30)),
    allergies: 'None',
    ongoing: 'Hypertension',
    treatments: [
      Treatment(
        date: DateTime(2025, 8, 10),
        type: 'Cavity Filling',
        cost: 400,
        estimatedSessions: 2,
        remainingSessions: 1,
      ),
    ],
    notes: 'Review scheduled after 1 month.',
    reportFiles: ['assets/images/xray.jpg'],
  ),
];

  Future<void> _openDetails(Patient p, int index) async {
    final result = await Navigator.push<Patient?>(
      context,
      MaterialPageRoute(
        builder: (_) => ViewPatientScreen(patient: p),
      ),
    );

    if (result != null) {
      setState(() {
        _patients[index] = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient updated successfully')),
      );
    }
  }

  Future<void> _addPatient() async {
    final newPatient = await Navigator.push<Patient?>(
      context,
      MaterialPageRoute(builder: (_) => const AddPatientScreen()),
    );

    if (newPatient != null) {
      final updatedPatient = await Navigator.push<Patient?>(
        context,
        MaterialPageRoute(
          builder: (_) => TreatmentTrackingScreen(patient: newPatient),
        ),
      );

      if (updatedPatient != null) {
        setState(() {
          _patients.add(updatedPatient);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient added successfully')),
        );
      }
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: _patients.isEmpty
          ? const Center(
              child: Text('No patients yet. Tap + to add.'),
            )
          : ListView.separated(
              itemCount: _patients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = _patients[index];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    'Last visit: ${_formatDate(p.lastVisit)} • ${p.status}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openDetails(p, index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPatient,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Patient'),
      ),
    );
  }
}
