import 'package:dental_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';

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
  bool _isLoading = false;

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

  void _save() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

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

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_nameCtrl.text} updated successfully!"),
        backgroundColor: const Color(0xFF23649E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Icon(
                        Icons.edit_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Edit Patient",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Update patient information",
                        style: TextStyle(
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

          // Form Content - Using SliverToBoxAdapter to prevent overflow
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
                      mainAxisSize: MainAxisSize.min, // Prevents overflow
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
                            // Constrain the treatment list to prevent overflow
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

                        // Files & Reports
                        _buildSectionCard(
                          title: "Files & Reports",
                          icon: Icons.folder_rounded,
                          children: [
                            if (_reportFiles.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.folder_open_rounded, color: Colors.grey),
                                    SizedBox(width: 12),
                                    Text(
                                      "No reports uploaded yet",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            else
                              // Constrain file list to prevent overflow
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _reportFiles.length,
                                  itemBuilder: (context, i) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF23649E).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.insert_drive_file_rounded,
                                          color: Color(0xFF23649E),
                                        ),
                                      ),
                                      title: Text(
                                        _reportFiles[i],
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                        onPressed: () {
                                          setState(() => _reportFiles.removeAt(i));
                                        },
                                      ),
                                    ),
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
                                onPressed: () {
                                  setState(() => _reportFiles.add("new_report_${DateTime.now().millisecondsSinceEpoch}.png"));
                                },
                                icon: const Icon(Icons.upload_file_rounded, color: Color(0xFF23649E)),
                                label: const Text(
                                  "Add Report",
                                  style: TextStyle(
                                    color: Color(0xFF23649E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Save Button
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
                            onPressed: _isLoading ? null : _save,
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
                                : const Icon(Icons.check_rounded, color: Colors.white),
                            label: Text(
                              _isLoading ? "Saving Changes..." : "Save Changes",
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
          mainAxisSize: MainAxisSize.min, // Prevents overflow
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF23649E),
                    ),
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
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
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
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF23649E), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}