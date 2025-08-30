import 'package:dental_app/screens/profile_screen.dart';
import 'package:dental_app/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class Patient {
  final String name;
  final String status;
  final String lastVisit;

  Patient({required this.name, required this.status, required this.lastVisit});
}

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {

bool _isDrawerOpen = false;

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  final List<Patient> patients = [
    Patient(name: "Sanket Angane", status: "New", lastVisit: "12/10/2025"),
    Patient(name: "Shivam Chavan", status: "Under Treatment", lastVisit: "22/01/2025"),
    Patient(name: "Muskan Gupta", status: "Under Treatment", lastVisit: "11/09/2025"),
    Patient(name: "Anuja Mhaiskar", status: "New", lastVisit: "21/03/2025"),
    Patient(name: "Sahil Mayekar", status: "Follow Up", lastVisit: "05/09/2025"),
    Patient(name: "Prashant Gore", status: "New", lastVisit: "19/12/2025"),
    Patient(name: "Sanket Angane", status: "Completed", lastVisit: "01/07/2025"),
    Patient(name: "Shivam Chavan", status: "Follow Up", lastVisit: "13/11/2025"),
    Patient(name: "Sankalp Jangali", status: "Under Treatment", lastVisit: "12/02/2025"),
  ];

  Color _statusColor(String status) {
    switch (status) {
      case "New":
        return Colors.blue.shade600;
      case "Under Treatment":
        return Colors.orange.shade600;
      case "Follow Up":
        return Colors.purple.shade600;
      case "Completed":
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(isDrawerOpen: _isDrawerOpen,
            toggleDrawer: toggleDrawer,), // ✅ Drawer handled by Scaffold
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // ✅ open drawer properly
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search Box
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search....",
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 📋 Title
                const Text(
                  "View Patient List",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),

                if (isWide)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(flex: 3, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Last Visit", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailScreen(patient: patient),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          elevation: 4,
                          shadowColor: Colors.blue.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: isWide
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(patient.name,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: _statusChip(patient.status),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(patient.lastVisit,
                                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(patient.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          _statusChip(patient.status),
                                          const Spacer(),
                                          Text(patient.lastVisit,
                                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                        ],
                                      )
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add new patient clicked")),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// 📄 Patient Detail Screen
class PatientDetailScreen extends StatelessWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("👤 Name: ${patient.name}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text("📌 Status: ${patient.status}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text("📅 Last Visit: ${patient.lastVisit}", style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
