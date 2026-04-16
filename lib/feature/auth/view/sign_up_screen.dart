

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../model/auth_user_model.dart';
import '../viewmodel/auth_view_model.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final UserModel user; // ✅ RECEIVE USER
  const SignupScreen({
    super.key,
    required this.user,
  });
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final professionController = TextEditingController();
  final pincodeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    /// ✅ PREFILL DATA
    final user = widget.user;
    nameController.text = user.name;
    phoneController.text = user.phone;
    cityController.text = user.city;
    professionController.text = user.profession;
    pincodeController.text = user.pincode;
  }
  // ---------------- UI DECORATION ----------------
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  // ---------------- VALIDATION ----------------
  // String? _validateEmail(String? value) {
  //   if (value == null || value.isEmpty) return "Enter email";
  //   final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  //   if (!regex.hasMatch(value)) return "Invalid email";
  //   return null;
  // }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    final cleaned = value.replaceAll(' ', '');
    final regex = RegExp(r'^(\+91)?[6-9]\d{9}$');
    if (!regex.hasMatch(cleaned)) return "Invalid mobile number";
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Enter pincode";
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return "Enter valid 6-digit pincode";
    }
    return null;
  }

  // ---------------- SUBMIT ----------------
  // void _submit() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   final authController = ref.read(authViewModelProvider.notifier);
  //   const userId = 18;
  //   await authController.updateUserProfile(
  //     context: context,
  //     id: userId,
  //     name: nameController.text.trim(),
  //     email: emailController.text.trim(),
  //     city: cityController.text.trim(),
  //     profession: professionController.text.trim(),
  //     pincode: pincodeController.text.trim(),
  //   );
  // }

  /// ---------------- SUBMIT ----------------
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authController = ref.read(authViewModelProvider.notifier);
    await authController.updateUserProfile(
      context: context,
      id: widget.user.id, // ✅ FIXED
      name: nameController.text.trim(),
      email: widget.user.email,
      city: cityController.text.trim(),
      profession: professionController.text.trim(),
      pincode: pincodeController.text.trim(),
      phone: phoneController.text.trim(),
      uid: widget.user.fireBaseId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.blueBrandGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            "Complete Your Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Let’s set up your account in a few steps",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.user.email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 30),

                // FORM
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: nameController,
                        hint: "Full Name",
                        icon: Icons.person,
                        validator: (v) =>
                        v!.isEmpty ? "Enter name" : null,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: phoneController,
                        hint: "Enter Mobile Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: _validateMobile,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: cityController,
                        hint: "City",
                        icon: Icons.location_city,
                        validator: (v) =>
                        v!.isEmpty ? "Enter city" : null,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: professionController,
                        hint: "Profession",
                        icon: Icons.work,
                        validator: (v) =>
                        v!.isEmpty ? "Enter profession" : null,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: pincodeController,
                        hint: "Pincode",
                        icon: Icons.pin_drop,
                        keyboardType: TextInputType.number,
                        validator: _validatePincode,
                      ),

                      const SizedBox(height: 40),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: AppColors.blueActionGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: isLoading
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- REUSABLE FIELD ----------------
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hint, icon),
    );
  }
}