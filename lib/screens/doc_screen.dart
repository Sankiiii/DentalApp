import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/services/pinata_image_service.dart';
import 'package:dental_app/services/auth_service.dart' hide PinataService;
import 'package:dental_app/services/user_authintication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  final PinataService _pinataService = PinataService();
  
  bool _isLoading = false;
  bool _isUpdatingPassword = false;
  bool _isUploadingImage = false;
  bool _showPasswordSection = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _profileImageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
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
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = user!.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _specializationController.text = data['specialization'] ?? '';
          _clinicNameController.text = data['clinicName'] ?? '';
          _addressController.text = data['address'] ?? '';
          _profileImageUrl = data['profileImageUrl'];
        });
      } else {
        // Create user document if it doesn't exist
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
          'uid': user!.uid,
          'name': user!.displayName ?? '',
          'email': user!.email ?? '',
          'phone': '',
          'specialization': '',
          'clinicName': '',
          'address': '',
          'profileImageUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        setState(() {
          _emailController.text = user!.email ?? '';
          _nameController.text = user!.displayName ?? '';
        });
      }
    } catch (e) {
      _showError('Failed to load profile data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _uploadAndSaveProfileImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Upload image to Pinata
      final imageUrl = await _pinataService.uploadFile(_selectedImage!);
      
      if (imageUrl != null) {
        // Update Firestore with new image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
          'profileImageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _profileImageUrl = imageUrl;
          _selectedImage = null;
        });

        _showSuccess('Profile image updated successfully!');
      } else {
        _showError('Failed to upload image to Pinata');
      }
    } catch (e) {
      _showError('Failed to upload image: ${e.toString()}');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image first if selected
      if (_selectedImage != null) {
        await _uploadAndSaveProfileImage();
      }

      // Update Firestore profile data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'clinicName': _clinicNameController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSuccess('Profile updated successfully!');
    } catch (e) {
      _showError('Failed to update profile: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.trim().isEmpty ||
        _newPasswordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showError('All password fields are required');
      return;
    }

    if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showError('New passwords do not match');
      return;
    }

    if (_newPasswordController.text.trim().length < 6) {
      _showError('New password must be at least 6 characters');
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      // Re-authenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _oldPasswordController.text.trim(),
      );
      
      await user!.reauthenticateWithCredential(credential);

      // Update password
      await user!.updatePassword(_newPasswordController.text.trim());

      // Clear password fields
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      setState(() {
        _showPasswordSection = false;
      });

      _showSuccess('Password updated successfully!');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to update password';
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please logout and login again before changing password';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        default:
          errorMessage = 'Authentication error: ${e.message}';
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('Failed to update password: ${e.toString()}');
    } finally {
      setState(() {
        _isUpdatingPassword = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await _showLogoutDialog();
    if (confirmed) {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        _showError('Failed to logout: ${e.toString()}');
      }
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _buildImageUrl(String? imageRef) {
    if (imageRef == null || imageRef.isEmpty) return '';
    if (imageRef.startsWith('http')) return imageRef;
    return 'https://gateway.pinata.cloud/ipfs/$imageRef';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _clinicNameController.dispose();
    _addressController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF23649E),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF23649E).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    )
                  : _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? Image.network(
                          _buildImageUrl(_profileImageUrl),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF23649E),
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFF23649E).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xFF23649E),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _nameController.text.isNotEmpty 
                                        ? _nameController.text[0].toUpperCase() 
                                        : "Dr",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF23649E),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF23649E).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF23649E),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _nameController.text.isNotEmpty 
                                    ? _nameController.text[0].toUpperCase() 
                                    : "Dr",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF23649E),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          if (_isUploadingImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF23649E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                onPressed: _isUploadingImage ? null : _pickImage,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                tooltip: 'Change Profile Picture',
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
      margin: const EdgeInsets.only(bottom: 20),
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

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Text(
            "Please login to view profile",
            style: TextStyle(fontSize: 18, color: Color(0xFF23649E)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 220,
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
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  onPressed: _logout,
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
                      _buildProfileImage(),
                      const SizedBox(height: 16),
                      const Text(
                        "Doctor Profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user!.email ?? "",
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

          // Profile Content
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF23649E)),
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Personal Information
                              _buildSectionCard(
                                title: "Personal Information",
                                icon: Icons.person_rounded,
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: _inputDecoration(
                                      "Full Name",
                                      icon: Icons.badge_rounded,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: _inputDecoration(
                                      "Email",
                                      icon: Icons.email_rounded,
                                    ),
                                    enabled: false,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: _inputDecoration(
                                      "Phone Number",
                                      icon: Icons.phone_rounded,
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ],
                              ),

                              // Professional Information
                              _buildSectionCard(
                                title: "Professional Information",
                                icon: Icons.medical_services_rounded,
                                children: [
                                  TextFormField(
                                    controller: _specializationController,
                                    decoration: _inputDecoration(
                                      "Specialization",
                                      icon: Icons.local_hospital_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _clinicNameController,
                                    decoration: _inputDecoration(
                                      "Clinic/Hospital Name",
                                      icon: Icons.business_rounded,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: _inputDecoration(
                                      "Address",
                                      icon: Icons.location_on_rounded,
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),

                              // Security Section
                              _buildSectionCard(
                                title: "Security",
                                icon: Icons.security_rounded,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: _showPasswordSection
                                          ? Colors.red.withOpacity(0.1)
                                          : const Color(0xFF23649E).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _showPasswordSection
                                            ? Colors.red.withOpacity(0.3)
                                            : const Color(0xFF23649E).withOpacity(0.3),
                                      ),
                                    ),
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _showPasswordSection = !_showPasswordSection;
                                          if (!_showPasswordSection) {
                                            _oldPasswordController.clear();
                                            _newPasswordController.clear();
                                            _confirmPasswordController.clear();
                                          }
                                        });
                                      },
                                      icon: Icon(
                                        _showPasswordSection
                                            ? Icons.cancel_rounded
                                            : Icons.lock_rounded,
                                        color: _showPasswordSection
                                            ? Colors.red
                                            : const Color(0xFF23649E),
                                      ),
                                      label: Text(
                                        _showPasswordSection
                                            ? "Cancel Password Change"
                                            : "Change Password",
                                        style: TextStyle(
                                          color: _showPasswordSection
                                              ? Colors.red
                                              : const Color(0xFF23649E),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  if (_showPasswordSection) ...[
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _oldPasswordController,
                                      decoration: _inputDecoration(
                                        "Current Password",
                                        icon: Icons.lock_outline_rounded,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureOldPassword
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureOldPassword = !_obscureOldPassword;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: _obscureOldPassword,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _newPasswordController,
                                      decoration: _inputDecoration(
                                        "New Password",
                                        icon: Icons.lock_rounded,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureNewPassword
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureNewPassword = !_obscureNewPassword;
                                            });
                                          },
                                        ),
                                      ),obscureText: _obscureNewPassword,
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      decoration: _inputDecoration(
                                        "Confirm New Password",
                                        icon: Icons.lock_rounded,
                                      ).copyWith(
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_rounded
                                                : Icons.visibility_off_rounded,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword = !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: _obscureConfirmPassword,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: _isUpdatingPassword ? null : _changePassword,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: _isUpdatingPassword
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text(
                                                "Update Password",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Update Profile Button
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
                                    onTap: _isLoading ? null : _updateProfile,
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
                                              "Update Profile",
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
}

