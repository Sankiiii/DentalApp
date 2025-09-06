import 'package:flutter/material.dart';
import 'package:dental_app/screens/profile_screen.dart'; // contains Patient model

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _ongoingController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = "Active"; // Default dropdown value

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      final newPatient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        phone: _phoneController.text.trim(),
        dob: _dobController.text.trim(),
        address: _addressController.text.trim(),
        status: _status,
        lastVisit: DateTime.now(),
        allergies: _allergiesController.text.trim(),
        ongoing: _ongoingController.text.trim(),
        treatments: [],
        notes: _notesController.text.trim(),
        reportFiles: [],
      );

      // ✅ return patient to PatientListScreen
      Navigator.pop(context, newPatient);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _ongoingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.blue.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Patient"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Full Name", Icons.person),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter patient's name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Age", Icons.calendar_today),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter age" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Phone Number", Icons.phone),
                validator: (v) =>
                    v == null || v.length < 10 ? "Enter valid phone" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                decoration: _inputDecoration("Date of Birth (dd/mm/yyyy)", Icons.cake),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration("Address", Icons.home),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: _inputDecoration("Status", Icons.check_circle),
                items: ["Active", "Follow-up", "Completed"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _allergiesController,
                decoration: _inputDecoration("Allergies", Icons.warning),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ongoingController,
                decoration: _inputDecoration("Ongoing Conditions", Icons.medical_services),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration("Notes", Icons.note),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  "Save Patient",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: _savePatient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
