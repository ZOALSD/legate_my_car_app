import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class AddCarView extends StatefulWidget {
  const AddCarView({super.key});

  @override
  State<AddCarView> createState() => _AddCarViewState();
}

class _AddCarViewState extends State<AddCarView> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _locationController = TextEditingController();
  final _conditionDescriptionController = TextEditingController();

  String _selectedCondition = 'abandoned';
  bool _isLoading = false;

  final List<String> _conditionOptions = [
    'abandoned',
    'damaged',
    'burned',
    'other',
  ];

  @override
  void dispose() {
    _plateNumberController.dispose();
    _chassisNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    _conditionDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'ADD_CAR_TITLE'.tr,
          style: const TextStyle(
            color: AppTheme.sudanWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.sudanWhite,
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.secondaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ADD_CAR_DESCRIPTION'.tr,
                        style: const TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Car Images Section
              _buildSectionTitle('CAR_IMAGES'.tr),
              const SizedBox(height: 12),
              _buildImageUploadSection(),
              const SizedBox(height: 24),

              // Car Information Section
              _buildSectionTitle('CAR_DETAILS'.tr),
              const SizedBox(height: 16),

              // Plate Number
              _buildTextField(
                controller: _plateNumberController,
                label: 'PLATE_NUMBER'.tr,
                hint: 'Enter plate number (optional)',
                required: false,
              ),
              const SizedBox(height: 16),

              // Chassis Number
              _buildTextField(
                controller: _chassisNumberController,
                label: 'CHASSIS_NUMBER'.tr,
                hint: 'Enter chassis number (optional)',
                required: false,
              ),
              const SizedBox(height: 16),

              // Brand and Model Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _brandController,
                      label: 'BRAND'.tr,
                      hint: 'e.g., Toyota',
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _modelController,
                      label: 'MODEL'.tr,
                      hint: 'e.g., Corolla',
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color
              _buildTextField(
                controller: _colorController,
                label: 'COLOR'.tr,
                hint: 'e.g., White, Black, Red',
                required: true,
              ),
              const SizedBox(height: 16),

              // Location
              _buildTextField(
                controller: _locationController,
                label: 'LOCATION'.tr,
                hint: 'Where did you find this car?',
                required: true,
              ),
              const SizedBox(height: 24),

              // Car Condition Section
              _buildSectionTitle('CAR_CONDITION'.tr),
              const SizedBox(height: 16),

              // Condition Selection
              _buildConditionSelector(),
              const SizedBox(height: 16),

              // Condition Description
              _buildTextField(
                controller: _conditionDescriptionController,
                label: 'CONDITION_DESCRIPTION'.tr,
                hint: 'ENTER_CONDITION_DETAILS'.tr,
                required: true,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCarReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.sudanWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.sudanWhite,
                            ),
                          ),
                        )
                      : Text(
                          'SUBMIT_CAR_REPORT'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool required,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            'UPLOAD_IMAGES'.tr,
            style: const TextStyle(
              color: AppTheme.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Take photos from different angles',
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CAR_CONDITION'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _conditionOptions.map((condition) {
            return ChoiceChip(
              label: Text(condition.tr),
              selected: _selectedCondition == condition,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCondition = condition;
                  });
                }
              },
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submitCarReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      Get.snackbar(
        'SUCCESS'.tr,
        'CAR_REPORT_SUCCESS'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.secondaryColor,
        colorText: AppTheme.sudanWhite,
        icon: const Icon(Icons.check_circle, color: AppTheme.sudanWhite),
      );

      // Clear form
      _clearForm();

      // Navigate back
      Get.back();
    } catch (e) {
      // Show error message
      Get.snackbar(
        'ERROR'.tr,
        'CAR_REPORT_ERROR'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: AppTheme.sudanWhite,
        icon: const Icon(Icons.error, color: AppTheme.sudanWhite),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _plateNumberController.clear();
    _chassisNumberController.clear();
    _brandController.clear();
    _modelController.clear();
    _colorController.clear();
    _locationController.clear();
    _conditionDescriptionController.clear();
    _selectedCondition = 'abandoned';
  }
}
