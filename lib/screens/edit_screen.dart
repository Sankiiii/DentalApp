import 'package:dental_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'patient_screen.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient patient;

  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _statusCtrl;
  late TextEditingController _lastVisitCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _ongoingCtrl;
  late TextEditingController _notesCtrl;

  late List<Treatment> _treatments;
  late List<String> _reportFiles;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameCtrl = TextEditingController(text: p.name);
    _ageCtrl = TextEditingController(text: p.age.toString());
    _dobCtrl = TextEditingController(text: p.dob);
    _phoneCtrl = TextEditingController(text: p.phone);
    _addressCtrl = TextEditingController(text: p.address);
    _statusCtrl = TextEditingController(text: p.status);
    _lastVisitCtrl =
        TextEditingController(text: p.lastVisit.toIso8601String().substring(0, 10));
    _allergiesCtrl = TextEditingController(text: p.allergies);
    _ongoingCtrl = TextEditingController(text: p.ongoing);
    _notesCtrl = TextEditingController(text: p.notes);
    _treatments = List.from(p.treatments);
    _reportFiles = List.from(p.reportFiles);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _statusCtrl.dispose();
    _lastVisitCtrl.dispose();
    _allergiesCtrl.dispose();
    _ongoingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final parsedAge = int.tryParse(_ageCtrl.text.trim()) ?? widget.patient.age;
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(_lastVisitCtrl.text.trim());
    } catch (_) {
      parsedDate = widget.patient.lastVisit;
    }

    final updated = widget.patient.copyWith(
      name: _nameCtrl.text.trim(),
      age: parsedAge,
      phone: _phoneCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      status: _statusCtrl.text.trim(),
      lastVisit: parsedDate,
      allergies: _allergiesCtrl.text.trim(),
      ongoing: _ongoingCtrl.text.trim(),
      treatments: _treatments,
      notes: _notesCtrl.text.trim(),
      reportFiles: _reportFiles,
    );

    Navigator.pop(context, updated);
  }

  void _addTreatment() {
    setState(() {
      _treatments.add(
        Treatment(
          date: DateTime.now(),
          type: 'New Treatment',
          cost: 0,
          estimatedSessions: 1,
          remainingSessions: 1,
        ),
      );
    });
  }

  void _removeTreatment(int index) {
    setState(() {
      _treatments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = (String label) => InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: _save,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info
            Text("Basic Info", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: inputDecoration("Name"),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ageCtrl,
              decoration: inputDecoration("Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dobCtrl,
              decoration: inputDecoration("DOB (dd/mm/yyyy)"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: inputDecoration("Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: inputDecoration("Address"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _statusCtrl,
              decoration: inputDecoration("Status"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastVisitCtrl,
              decoration: inputDecoration("Last Visit (yyyy-mm-dd)"),
            ),

            const SizedBox(height: 20),
            Text("Medical History",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _allergiesCtrl,
              decoration: inputDecoration("Allergies"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ongoingCtrl,
              decoration: inputDecoration("Ongoing Conditions"),
            ),

            const SizedBox(height: 20),
            Text("Treatment History",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Column(
              children: [
                for (int i = 0; i < _treatments.length; i++)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: _treatments[i].type,
                            decoration: const InputDecoration(labelText: "Type"),
                            onChanged: (v) =>
                                _treatments[i] = _treatments[i].copyWith(type: v),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _treatments[i].cost.toString(),
                            decoration: const InputDecoration(labelText: "Cost"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final cost = double.tryParse(v) ?? 0;
                              _treatments[i] =
                                  _treatments[i].copyWith(cost: cost);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                _treatments[i].estimatedSessions.toString(),
                            decoration: const InputDecoration(
                                labelText: "Estimated Sessions"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final est = int.tryParse(v) ?? 1;
                              _treatments[i] =
                                  _treatments[i].copyWith(estimatedSessions: est);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue:
                                _treatments[i].remainingSessions.toString(),
                            decoration: const InputDecoration(
                                labelText: "Remaining Sessions"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final rem = int.tryParse(v) ?? 0;
                              _treatments[i] =
                                  _treatments[i].copyWith(remainingSessions: rem);
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeTreatment(i),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _addTreatment,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Treatment"),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text("Dentist Notes",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: inputDecoration("Notes"),
            ),

            const SizedBox(height: 20),
            Text("Files & Reports",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Column(
              children: [
                for (int i = 0; i < _reportFiles.length; i++)
                  ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(_reportFiles[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _reportFiles.removeAt(i));
                      },
                    ),
                  ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _reportFiles.add("new_report.png"));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Report"),
                ),
              ],
            ),

            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
