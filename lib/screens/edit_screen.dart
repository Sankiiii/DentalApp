import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/screens/profile_screen.dart';
import 'package:dental_app/services/pinata_image_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient patient;

  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  List<File> _newAttachments = [];
  bool _isLoading = false;
  bool _isUploading = false;

  final user = FirebaseAuth.instance.currentUser;

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

    final p = widget.patient;
    _nameCtrl = TextEditingController(text: p.name);
    _ageCtrl = TextEditingController(text: p.age.toString());
    _dobCtrl = TextEditingController(text: p.dob);
    _phoneCtrl = TextEditingController(text: p.phone);
    _addressCtrl = TextEditingController(text: p.address);
    _statusCtrl = TextEditingController(text: p.status);
    _lastVisitCtrl = TextEditingController(text: p.lastVisit.toIso8601String().substring(0, 10));
    _allergiesCtrl = TextEditingController(text: p.allergies);
    _ongoingCtrl = TextEditingController(text: p.ongoing);
    _notesCtrl = TextEditingController(text: p.notes);
    _treatments = List.from(p.treatments);
    _reportFiles = List.from(p.reportFiles);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _newAttachments.addAll(result.paths.map((p) => File(p!)));
      });
    }
  }

  void _removeNewAttachment(int index) {
    setState(() {
      _newAttachments.removeAt(index);
    });
  }

  void _removeExistingFile(int index) {
    setState(() {
      _reportFiles.removeAt(index);
    });
  }

  void _save() async {
    if (_formKey.currentState?.validate() != true) return;
    if (user == null) {
      _showError("User not logged in");
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = _newAttachments.isNotEmpty;
    });

    try {
      // Upload new files to Pinata
      List<String> uploadedUrls = [];
      for (int i = 0; i < _newAttachments.length; i++) {
        final url = await PinataService().uploadFile(_newAttachments[i]);
        if (url != null) uploadedUrls.add(url);
      }

      // Combine existing and new files
      final allFiles = [..._reportFiles, ...uploadedUrls];

      final parsedAge = int.tryParse(_ageCtrl.text.trim()) ?? widget.patient.age;
      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(_lastVisitCtrl.text.trim());
      } catch (_) {
        parsedDate = widget.patient.lastVisit;
      }

      // Convert treatments to Firebase-compatible format
      final treatmentMaps = _treatments.map((t) => {
        'date': t.date.toIso8601String(),
        'type': t.type,
        'cost': t.cost,
        'estimatedSessions': t.estimatedSessions,
        'remainingSessions': t.remainingSessions,
      }).toList();

      // Update patient in Firebase
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("patients")
          .doc(widget.patient.id)
          .update({
        "name": _nameCtrl.text.trim(),
        "age": parsedAge,
        "phone": _phoneCtrl.text.trim(),
        "dob": _dobCtrl.text.trim(),
        "address": _addressCtrl.text.trim(),
        "status": _statusCtrl.text.trim(),
        "lastVisit": Timestamp.fromDate(parsedDate),
        "allergies": _allergiesCtrl.text.trim(),
        "ongoing": _ongoingCtrl.text.trim(),
        "notes": _notesCtrl.text.trim(),
        "treatments": treatmentMaps,
        "reportFiles": allFiles,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // Create updated patient object for navigation
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
        reportFiles: allFiles,
      );

      _showSuccess("${_nameCtrl.text} updated successfully!");
      Navigator.pop(context, updated);

    } catch (e) {
      _showError("Failed to update patient: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
        _isUploading = false;
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF23649E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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

  String _buildImageUrl(String ref) {
    if (ref.startsWith("http")) {
      return ref;
    }
    return "https://gateway.pinata.cloud/ipfs/$ref";
  }

  Widget _buildImagePreview(String imageUrl, {VoidCallback? onDelete}) {
    return Container(
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _buildImageUrl(imageUrl),
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_rounded, color: Colors.grey, size: 30),
                    SizedBox(height: 4),
                    Text("Image\nNot Found", 
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF23649E)),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                  onPressed: onDelete,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ),
            ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 160,
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
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  onPressed: _isLoading ? null : _save,
                ),
              ),
            ],
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            widget.patient.name.isNotEmpty 
                              ? widget.patient.name[0].toUpperCase() 
                              : "?",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF23649E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Edit Patient",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Update ${widget.patient.name}'s information",
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Basic Information
                        _buildSectionCard(
                          title: "Basic Information",
                          icon: Icons.person_rounded,
                          children: [
                            _buildTextField(
                              controller: _nameCtrl,
                              label: "Name",
                              icon: Icons.person_outline_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty) 
                                ? 'Name is required' : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _ageCtrl,
                                    label: "Age",
                                    icon: Icons.cake_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _dobCtrl,
                                    label: "DOB (dd/mm/yyyy)",
                                    icon: Icons.calendar_today_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _phoneCtrl,
                              label: "Phone",
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _addressCtrl,
                              label: "Address",
                              icon: Icons.home_rounded,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _statusCtrl,
                              label: "Status",
                              icon: Icons.check_circle_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _lastVisitCtrl,
                              label: "Last Visit (yyyy-mm-dd)",
                              icon: Icons.schedule_rounded,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Medical History
                        _buildSectionCard(
                          title: "Medical History",
                          icon: Icons.health_and_safety_rounded,
                          children: [
                            _buildTextField(
                              controller: _allergiesCtrl,
                              label: "Allergies",
                              icon: Icons.warning_amber_rounded,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _ongoingCtrl,
                              label: "Ongoing Conditions",
                              icon: Icons.medical_services_rounded,
                              maxLines: 2,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Treatment History
                        _buildSectionCard(
                          title: "Treatment History",
                          icon: Icons.medical_information_rounded,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.4,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...List.generate(_treatments.length, (i) => Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFF23649E).withOpacity(0.2),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFF23649E).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.healing_rounded,
                                                    color: Color(0xFF23649E),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    "Treatment ${i + 1}",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF23649E),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                                  onPressed: () => _removeTreatment(i),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              initialValue: _treatments[i].type,
                                              decoration: _inputDecoration("Treatment Type"),
                                              onChanged: (v) =>
                                                  _treatments[i] = _treatments[i].copyWith(type: v),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: _treatments[i].cost.toString(),
                                                    decoration: _inputDecoration("Cost (₹)"),
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (v) {
                                                      final cost = double.tryParse(v) ?? 0;
                                                      _treatments[i] = _treatments[i].copyWith(cost: cost);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: TextFormField(
                                                    initialValue: _treatments[i].estimatedSessions.toString(),
                                                    decoration: _inputDecoration("Est. Sessions"),
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (v) {
                                                      final est = int.tryParse(v) ?? 1;
                                                      _treatments[i] = _treatments[i].copyWith(estimatedSessions: est);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            TextFormField(
                                              initialValue: _treatments[i].remainingSessions.toString(),
                                              decoration: _inputDecoration("Remaining Sessions"),
                                              keyboardType: TextInputType.number,
                                              onChanged: (v) {
                                                final rem = int.tryParse(v) ?? 0;
                                                _treatments[i] = _treatments[i].copyWith(remainingSessions: rem);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF23649E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF23649E).withOpacity(0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: TextButton.icon(
                                onPressed: _addTreatment,
                                icon: const Icon(Icons.add_rounded, color: Color(0xFF23649E)),
                                label: const Text(
                                  "Add Treatment",
                                  style: TextStyle(
                                    color: Color(0xFF23649E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Doctor Notes
                        _buildSectionCard(
                          title: "Doctor Notes",
                          icon: Icons.note_alt_rounded,
                          children: [
                            _buildTextField(
                              controller: _notesCtrl,
                              label: "Notes",
                              icon: Icons.edit_note_rounded,
                              maxLines: 4,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Files & Reports with Image Preview
                        _buildSectionCard(
                          title: "Reports & Images",
                          icon: Icons.folder_rounded,
                          children: [
                            // Existing Files
                            if (_reportFiles.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.photo_library_rounded, color: Color(0xFF23649E), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Current Files (${_reportFiles.length})",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF23649E),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                children: List.generate(_reportFiles.length, (i) => 
                                  _buildImagePreview(_reportFiles[i], onDelete: () => _removeExistingFile(i))
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // New Files
                            if (_newAttachments.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.new_releases_rounded, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "New Files (${_newAttachments.length})",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                children: List.generate(_newAttachments.length, (i) => Container(
                                  margin: const EdgeInsets.only(right: 12, bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 120,
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(_getFileIcon(_newAttachments[i].path), 
                                              color: const Color(0xFF23649E), size: 40),
                                            const SizedBox(height: 8),
                                            Text(
                                              _newAttachments[i].path.split('/').last,
                                              style: const TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                            onPressed: () => _removeNewAttachment(i),
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Add Files Button
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
                                  "Add X-rays, Reports, Images",
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
// Upload Progress
                            if (_isUploading) ...[
                              const SizedBox(height: 16),
                              Container(
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
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Save Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF23649E), Color(0xFF1565C0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF23649E).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _save,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Update Patient",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                    color: const Color(0xFF23649E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF23649E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
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
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(label, icon: icon),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF23649E)) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF23649E), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}