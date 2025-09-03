import 'package:flutter/material.dart';

class AddEditPatientScreen extends StatefulWidget {
  final Map<String, dynamic>? patient; // null = add, not null = edit

  const AddEditPatientScreen({super.key, this.patient});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? treatmentStatus;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      // Check if "firstName" exists or only "name"
      if (widget.patient!.containsKey("firstName")) {
        firstNameController.text = widget.patient!["firstName"] ?? "";
        lastNameController.text = widget.patient!["lastName"] ?? "";
      } else if (widget.patient!.containsKey("name")) {
        // Split name into first + last
        final parts = widget.patient!["name"].toString().split(" ");
        firstNameController.text = parts.isNotEmpty ? parts.first : "";
        lastNameController.text =
            parts.length > 1 ? parts.sublist(1).join(" ") : "";
      }

      dobController.text = widget.patient!["dob"] ?? "";
      contactController.text = widget.patient!["contact"] ?? "";
      addressController.text = widget.patient!["address"] ?? "";
      treatmentStatus = widget.patient!["status"];
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.patient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Patient" : "Add Patient"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Details
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: "First Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: "Last Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // DOB & Contact
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        dobController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: contactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Contact",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Treatment Status
            const Text("Treatment Status",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text("New"),
                  selected: treatmentStatus == "New",
                  onSelected: (_) => setState(() => treatmentStatus = "New"),
                ),
                ChoiceChip(
                  label: const Text("Under Treatment"),
                  selected: treatmentStatus == "Under Treatment",
                  onSelected: (_) =>
                      setState(() => treatmentStatus = "Under Treatment"),
                ),
                ChoiceChip(
                  label: const Text("Follow Up"),
                  selected: treatmentStatus == "Follow Up",
                  onSelected: (_) =>
                      setState(() => treatmentStatus = "Follow Up"),
                ),
                ChoiceChip(
                  label: const Text("Completed"),
                  selected: treatmentStatus == "Completed",
                  onSelected: (_) =>
                      setState(() => treatmentStatus = "Completed"),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final patientData = {
                    "firstName": firstNameController.text,
                    "lastName": lastNameController.text,
                    "dob": dobController.text,
                    "contact": contactController.text,
                    "address": addressController.text,
                    "status": treatmentStatus,
                  };

                  Navigator.pop(context, patientData); // Return data back
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(isEditing ? "Update" : "Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
