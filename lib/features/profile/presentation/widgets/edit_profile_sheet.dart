import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vezu/features/auth/domain/entities/user_entity.dart';
import 'package:vezu/features/auth/presentation/cubit/auth_cubit.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({required this.user, super.key});

  final UserEntity? user;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _ageController;
  String? _selectedGender;
  File? _selectedImageFile;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.user?.lastName ?? '');
    _ageController = TextEditingController(
      text: widget.user?.age?.toString() ?? '',
    );
    _selectedGender = widget.user?.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
    });
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final authCubit = context.read<AuthCubit>();
    final age = int.tryParse(_ageController.text.trim());

    await authCubit.updateProfile(
      firstName: _firstNameController.text.trim().isEmpty
          ? null
          : _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      gender: _selectedGender,
      age: age,
      profilePhotoPath: _selectedImageFile?.path,
    );
    if (!mounted) return;
    if (!authCubit.state.hasError) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.14),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ?? 'authErrorGeneric'.tr()),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isSaving = state.isUpdatingProfile || _isPickingImage;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outline.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'profileEditProfile'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              backgroundImage: _selectedImageFile != null
                                  ? FileImage(_selectedImageFile!)
                                  : (user?.profilePhotoUrl != null
                                      ? NetworkImage(user!.profilePhotoUrl!)
                                      : null),
                              child: (user?.profilePhotoUrl == null &&
                                      _selectedImageFile == null)
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: isSaving ? null : _pickImage,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isSaving && _isPickingImage
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              context,
                              controller: _firstNameController,
                              label: 'profileEditFirstName'.tr(),
                              hint: 'profileEditFirstNameHint'.tr(),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              context,
                              controller: _lastNameController,
                              label: 'profileEditLastName'.tr(),
                              hint: 'profileEditLastNameHint'.tr(),
                            ),
                            const SizedBox(height: 16),
                            _buildGenderDropdown(theme),
                            const SizedBox(height: 16),
                            _buildTextField(
                              context,
                              controller: _ageController,
                              label: 'profileEditAge'.tr(),
                              hint: 'profileEditAgeHint'.tr(),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final parsed = int.tryParse(value.trim());
                                if (parsed == null || parsed <= 0) {
                                  return 'profileEditErrorInvalidAge'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text('profileEditSave'.tr()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profileEditGender'.tr(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          items: [
            DropdownMenuItem(
              value: 'male',
              child: Text('profileGenderMale'.tr()),
            ),
            DropdownMenuItem(
              value: 'female',
              child: Text('profileGenderFemale'.tr()),
            ),
            DropdownMenuItem(
              value: 'other',
              child: Text('profileGenderOther'.tr()),
            ),
          ],
          onChanged: (value) => setState(() => _selectedGender = value),
          decoration: InputDecoration(
            hintText: 'profileEditGenderHint'.tr(),
          ),
        ),
      ],
    );
  }
}

