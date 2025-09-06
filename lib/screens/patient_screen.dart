import 'package:flutter/material.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${patient["firstName"]} ${patient["lastName"]}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info
            Center(
              child: Text(
                "${patient["firstName"]} ${patient["lastName"]}",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
            const SizedBox(height: 8),
            infoRow("DOB", patient["dob"]),
            infoRow("Contact", patient["contact"]),
            infoRow("Address", patient["address"]),
            const SizedBox(height: 15),

            // Medical History
            sectionHeader("Medical History"),
            const SizedBox(height: 6),
            infoRow("Allergies", patient["medicalHistory"]["allergies"]),
            infoRow("Ongoing", patient["medicalHistory"]["ongoing"]),
            const SizedBox(height: 15),

            // Treatment History
            sectionHeader("Treatment History"),
            const SizedBox(height: 6),
            DataTable(
              columns: const [
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Type")),
                DataColumn(label: Text("Cost")),
              ],
              rows: patient["treatmentHistory"]
                  .map<DataRow>((t) => DataRow(cells: [
                        DataCell(Text(t["date"])),
                        DataCell(Text(t["type"])),
                        DataCell(Text(t["cost"])),
                      ]))
                  .toList(),
            ),
            const SizedBox(height: 15),

            // Dentist Notes
            sectionHeader("Dentist Notes"),
            const SizedBox(height: 6),
            Text(patient["dentistNotes"]),
            const SizedBox(height: 15),

            // Files & Reports
            sectionHeader("Files & Reports"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: patient["filesReports"]
                  .map<Widget>(
                    (file) => OutlinedButton.icon(
                      onPressed: () {},
                      icon: file.contains("X-ray")
                          ? const Icon(Icons.image)
                          : const Icon(Icons.description),
                      label: Text(file),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 80), // space for bottom button
          ],
        ),
      ),

      // Bottom Edit Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.blue,
          ),
          onPressed: () async {
            // TODO: Navigate to Edit Screen
          },
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text(
            "Edit Details",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
