import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/screens/profile_screen.dart';
import 'package:dental_app/services/pinata_image_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TreatmentTrackingScreen extends StatefulWidget {
  final Patient patient;

  const TreatmentTrackingScreen({super.key, required this.patient});

  @override
  State<TreatmentTrackingScreen> createState() =>
      _TreatmentTrackingScreenState();
}

class _TreatmentTrackingScreenState extends State<TreatmentTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _procedureController = TextEditingController();
  final _costController = TextEditingController();
  final _estimatedSessionsController = TextEditingController();
  final _remainingSessionsController = TextEditingController();
  final _dateController = TextEditingController();

  List<File> _attachments = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachments.addAll(result.paths.map((p) => File(p!)));
      });
    }
  }



void _saveTreatment() async {
  if (_formKey.currentState!.validate()) {
    final estSessions = int.tryParse(_estimatedSessionsController.text) ?? 1;
    final remSessions =
        int.tryParse(_remainingSessionsController.text) ?? estSessions;

    final newTreatment = {
  "date": _dateController.text,
  "procedure": _procedureController.text.trim(),
  "cost": double.tryParse(_costController.text) ?? 0,
  "estimatedSessions": estSessions,
  "remainingSessions": remSessions,
  "createdAt": Timestamp.now(), // ✅ use client-side timestamp
};


    // ✅ Upload files to Pinata
    List<String> uploadedUrls = [];
    for (File f in _attachments) {
      final url = await PinataService().uploadFile(f);
      if (url != null) uploadedUrls.add(url);
    }

    // ✅ Get logged-in user UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ User not logged in");
      return;
    }

    // ✅ Save patient data in Firestore under the logged-in user
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("patients")
        .doc(widget.patient.id) // unique patient doc
        .set({
      "id": widget.patient.id,
      "name": widget.patient.name,
      "age": widget.patient.age,
      "phone": widget.patient.phone,
      "dob": widget.patient.dob,
      "address": widget.patient.address,
      "treatments": FieldValue.arrayUnion([newTreatment]),
      "reportFiles": FieldValue.arrayUnion(uploadedUrls),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }
}


  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Treatment Tracking"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Treatment Plan",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _procedureController,
                      decoration: _fieldDecoration("Procedure"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter procedure" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration("Cost"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter cost" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _estimatedSessionsController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration("Estimated Sessions"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter estimated sessions" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _remainingSessionsController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration("Remaining Sessions"),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateController,
                      decoration: _fieldDecoration("Start Date (yyyy-mm-dd)"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter start date" : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // File Upload Section
              ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Reports / X-rays"),
              ),
              const SizedBox(height: 10),
              if (_attachments.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _attachments
                      .map((f) => ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(f.path.split('/').last),
                          ))
                      .toList(),
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTreatment,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
