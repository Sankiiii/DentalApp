import 'package:flutter/material.dart';

void main() {
  runApp(const DentalApp());
}

class DentalApp extends StatelessWidget {
  const DentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PatientDetailsScreen(),
    );
  }
}

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          "Sanket Angane",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info
            Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("DOB",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("01/07/2005", style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(width: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Contact",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("932186XXXX", style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text("Address",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const Text("Tambe Nagar, Mulund.",
                style: TextStyle(fontSize: 14)),

            const SizedBox(height: 16),

            // Medical History
            _sectionHeader("MEDICAL HISTORY"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Allergies",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text("Penicillin"),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Ongoing",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Text("diabetes"),
              ],
            ),

            const SizedBox(height: 16),

            // Treatment History
            _sectionHeader("TREATMENT HISTORY"),
            const SizedBox(height: 8),
            Table(
              border: const TableBorder(
                horizontalInside: BorderSide(color: Colors.grey, width: 0.5),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
              },
              children: const [
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("Date",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("Type",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("Cost",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("01/07/2025"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("Root Canal"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("₹ 500"),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("11/09/2025"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("Filling"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Text("₹ 700"),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dentist Notes
            _sectionHeader("Dentist Notes"),
            const SizedBox(height: 8),
            const Text("Patient reports pain in the lower right tooth"),

            const SizedBox(height: 16),

            // Files & Reports
            _sectionHeader("Files & Reports"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _fileButton(Icons.image, "X-ray"),
                _fileButton(Icons.insert_drive_file, "Report"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom section header
  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // File & Report buttons
  Widget _fileButton(IconData icon, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: () {},
      icon: Icon(icon, color: Colors.blue),
      label: Text(label),
    );
  }
}
