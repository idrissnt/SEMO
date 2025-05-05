import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// A bottom sheet that displays and allows editing of personal information
/// This is designed to be shown as a modal bottom sheet instead of a full screen
class PersonalInfoBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;

  const PersonalInfoBottomSheet({Key? key, this.scrollController})
      : super(key: key);

  @override
  State<PersonalInfoBottomSheet> createState() =>
      _PersonalInfoBottomSheetState();
}

class _PersonalInfoBottomSheetState extends State<PersonalInfoBottomSheet> {
  // Form controllers
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final _bioController = TextEditingController(
      text: 'Experienced handyman and grocery delivery driver.');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          _buildDragHandle(),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Scrollbar(
              thickness: 6,
              radius: const Radius.circular(10),
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Fields
                    _buildFormSection(),

                    const SizedBox(height: 32),

                    // Save Button
                    _buildSaveButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Full Name',
          controller: _nameController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Phone Number',
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Bio',
          controller: _bioController,
          icon: Icons.description_outlined,
          maxLines: 3,
          helperText: 'Tell us about yourself in a few sentences',
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimaryColor,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey[50] : Colors.white,
            helperText: helperText,
            helperStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Save user information
          _saveUserInformation();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _saveUserInformation() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      // Hide loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Close the bottom sheet
      Navigator.pop(context);
    });
  }
}
