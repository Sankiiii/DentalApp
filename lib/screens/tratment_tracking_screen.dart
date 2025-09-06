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

class _TreatmentTrackingScreenState extends State<TreatmentTrackingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _procedureController = TextEditingController();
  final _costController = TextEditingController();
  final _estimatedSessionsController = TextEditingController();
  final _remainingSessionsController = TextEditingController();
  final _dateController = TextEditingController();

  List<File> _attachments = [];
  bool _isLoading = false;
  bool _isUploading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();

    // Set default date to today
    _dateController.text = DateTime.now().toIso8601String().substring(0, 10);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _procedureController.dispose();
    _costController.dispose();
    _estimatedSessionsController.dispose();
    _remainingSessionsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachments.addAll(result.paths.map((p) => File(p!)));
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _saveTreatment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _isUploading = _attachments.isNotEmpty;
      });

      try {
        final estSessions = int.tryParse(_estimatedSessionsController.text) ?? 1;
        final remSessions = int.tryParse(_remainingSessionsController.text) ?? estSessions;

        final newTreatment = {
          "date": _dateController.text,
          "procedure": _procedureController.text.trim(),
          "cost": double.tryParse(_costController.text) ?? 0,
          "estimatedSessions": estSessions,
          "remainingSessions": remSessions,
          "createdAt": Timestamp.now(),
        };

        // Upload files to Pinata
        List<String> uploadedUrls = [];
        for (int i = 0; i < _attachments.length; i++) {
          setState(() {
            _isUploading = true;
          });
          final url = await PinataService().uploadFile(_attachments[i]);
          if (url != null) uploadedUrls.add(url);
        }

        // Get logged-in user UID
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("User not logged in");
        }

        // Save patient data in Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("patients")
            .doc(widget.patient.id)
            .set({
          "id": widget.patient.id,
          "name": widget.patient.name,
          "age": widget.patient.age,
          "phone": widget.patient.phone,
          "dob": widget.patient.dob,
          "address": widget.patient.address,
          "status": widget.patient.status,
          "allergies": widget.patient.allergies,
          "ongoing": widget.patient.ongoing,
          "notes": widget.patient.notes,
          "treatments": FieldValue.arrayUnion([newTreatment]),
          "reportFiles": FieldValue.arrayUnion(uploadedUrls),
          "lastVisit": Timestamp.now(),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Treatment plan created for ${widget.patient.name}!"),
            backgroundColor: const Color(0xFF23649E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF23649E),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF23649E), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_information_rounded,
                          size: 40,
                          color: Color(0xFF23649E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Treatment Planning",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Patient: ${widget.patient.name}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Treatment Plan Section
                        _buildSectionCard(
                          title: "Treatment Plan",
                          icon: Icons.healing_rounded,
                          children: [
                            _buildTextField(
                              controller: _procedureController,
                              label: "Procedure",
                              hint: "e.g., Root Canal, Cleaning, Filling",
                              icon: Icons.medical_services_rounded,
                              validator: (v) => v == null || v.isEmpty ? "Enter procedure" : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _costController,
                                    label: "Cost (₹)",
                                    hint: "0",
                                    icon: Icons.currency_rupee_rounded,
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || v.isEmpty ? "Enter cost" : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _dateController,
                                    label: "Start Date",
                                    hint: "YYYY-MM-DD",
                                    icon: Icons.calendar_today_rounded,
                                    validator: (v) => v == null || v.isEmpty ? "Enter start date" : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _estimatedSessionsController,
                                    label: "Estimated Sessions",
                                    hint: "1",
                                    icon: Icons.event_repeat_rounded,
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v == null || v.isEmpty ? "Enter estimated sessions" : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _remainingSessionsController,
                                    label: "Remaining Sessions",
                                    hint: "1",
                                    icon: Icons.timer_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // File Upload Section
                        _buildSectionCard(
                          title: "Reports & Documentation",
                          icon: Icons.upload_file_rounded,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF23649E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF23649E).withOpacity(0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: TextButton.icon(
                                onPressed: _isLoading ? null : _pickFiles,
                                icon: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF23649E)),
                                label: const Text(
                                  "Upload X-rays, Reports, Images",
                                  style: TextStyle(
                                    color: Color(0xFF23649E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),

                            if (_attachments.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.attach_file_rounded, color: Color(0xFF23649E)),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Selected Files (${_attachments.length})",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF23649E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...List.generate(_attachments.length, (index) => Container(
                                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF23649E).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getFileIcon(_attachments[index].path),
                                            color: const Color(0xFF23649E),
                                          ),
                                        ),
                                        title: Text(
                                          _attachments[index].path.split('/').last,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          _formatFileSize(_attachments[index].lengthSync()),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close_rounded, color: Colors.red),
                                          onPressed: () => _removeAttachment(index),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                      ),
                                    )),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],

                            if (_isUploading)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23649E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF23649E)),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Uploading files...",
                                      style: TextStyle(
                                        color: Color(0xFF23649E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Create Treatment Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF23649E), Color(0xFF1565C0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF23649E).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveTreatment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_task_rounded, color: Colors.white),
                            label: Text(
                              _isLoading ? "Creating Treatment..." : "Create Treatment Plan",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF23649E), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF23649E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF23649E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF23649E),
              size: 20,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF23649E),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}