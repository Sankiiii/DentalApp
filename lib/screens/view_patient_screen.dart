import 'package:dental_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'edit_screen.dart';

class ViewPatientScreen extends StatelessWidget {
  final Patient patient;

  const ViewPatientScreen({super.key, required this.patient});

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.push<Patient?>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPatientScreen(patient: patient),
      ),
    );

    if (updated != null && context.mounted) {
      Navigator.pop(context, updated); // send updated back to list
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = patient;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit",
            onPressed: () => _edit(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            context,
            title: "Basic Info",
            icon: Icons.person,
            children: [
              _row("Patient ID", p.id),
              _row("Name", p.name),
              _row("Age", "${p.age}"),
              _row("DOB", p.dob),
              _row("Phone", p.phone),
              _row("Address", p.address),
              _row("Status", p.status),
              _row("Last Visit", _formatDate(p.lastVisit)),
            ],
          ),

          _sectionCard(
            context,
            title: "Medical History",
            icon: Icons.health_and_safety,
            children: [
              _row("Allergies", p.allergies.isEmpty ? "—" : p.allergies),
              _row("Ongoing Conditions", p.ongoing.isEmpty ? "—" : p.ongoing),
            ],
          ),

          _sectionCard(
            context,
            title: "Treatment History",
            icon: Icons.medical_services,
            children: [
              if (p.treatments.isEmpty)
                const Text("No treatments recorded.")
              else
                Column(
                  children: p.treatments.map((t) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.healing, color: Colors.blue),
                        title: Text(
                          t.type,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${_formatDate(t.date)}"),
                            Text("Estimated Sessions: ${t.estimatedSessions}"),
                            Text("Remaining Sessions: ${t.remainingSessions}"),
                          ],
                        ),
                        trailing: Text(
                          "₹${t.cost.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          _sectionCard(
            context,
            title: "Dentist Notes",
            icon: Icons.note_alt,
            children: [
              Text(
                p.notes.isEmpty ? "No notes" : p.notes,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),

          _sectionCard(
            context,
            title: "Reports & Files",
            icon: Icons.insert_drive_file,
            children: [
              if (p.reportFiles.isEmpty)
                const Text("No reports uploaded.")
              else
                Column(
                  children: p.reportFiles.map((f) {
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file,
                          color: Colors.red),
                      title: Text(f),
                    );
                  }).toList(),
                ),
            ],
          ),

          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit),
            label: const Text("Edit Details"),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
