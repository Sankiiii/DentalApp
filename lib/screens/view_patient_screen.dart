import 'package:dental_app/screens/add_patient.dart';
import 'package:flutter/material.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Map<String, dynamic>> patients = [
    {
      "firstName": "Sanket",
      "lastName": "Angane",
      "dob": "12/10/2000",
      "contact": "9876543210",
      "address": "Mumbai",
      "status": "New"
    },
    {
      "firstName": "Shivam",
      "lastName": "Chavan",
      "dob": "22/01/2001",
      "contact": "9988776655",
      "address": "Pune",
      "status": "Under Treatment"
    },
    {
      "firstName": "Muskan",
      "lastName": "Gupta",
      "dob": "11/09/2002",
      "contact": "9871234567",
      "address": "Delhi",
      "status": "Follow Up"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("View Patient List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: patients.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return GestureDetector(
                    onTap: () async {
                      final updatedPatient = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditPatientScreen(patient: patient),
                        ),
                      );

                      if (updatedPatient != null) {
                        setState(() {
                          patients[index] = updatedPatient;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "${patient["firstName"]} ${patient["lastName"]}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                patient["status"],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.lightBlue,
        onPressed: () async {
          final newPatient = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditPatientScreen(),
            ),
          );

          if (newPatient != null) {
            setState(() {
              patients.add(newPatient);
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Patient"),
      ),
    );
  }
}
