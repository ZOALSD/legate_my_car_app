import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/missing_car_model.dart';
import '../viewmodels/missing_car_viewmodel.dart';
import '../theme/app_theme.dart';
import 'location_picker_view.dart';

class LostCarFormView extends StatefulWidget {
  final MissingCarModel? car; // null for create, non-null for update

  const LostCarFormView({super.key, this.car});

  @override
  State<LostCarFormView> createState() => _LostCarFormViewState();
}

class _LostCarFormViewState extends State<LostCarFormView> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  double? _selectedLatitude;
  double? _selectedLongitude;

  bool get isUpdateMode => widget.car != null;

  @override
  void initState() {
    super.initState();
    if (isUpdateMode) {
      _populateFormFields();
    }
  }

  void _populateFormFields() {
    final car = widget.car!;
    _plateNumberController.text = car.plateNumber;
    _chassisNumberController.text = car.chassisNumber;
    _modelController.text = car.model;
    _colorController.text = car.color;
    _locationController.text = car.lastKnownLocation;
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _chassisNumberController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          isUpdateMode ? 'UPDATE_LOST_CAR'.tr : 'ADD_LOST_CAR'.tr,
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
              _buildDividerWithLabel('CAR_DETAILS'.tr),
              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _plateNumberController,
                        label: 'PLATE_NUMBER'.tr,
                        hint: 'Enter plate number',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _chassisNumberController,
                        label: 'CHASSIS_NUMBER'.tr,
                        hint: 'Enter chassis number',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _modelController,
                        label: 'MODEL'.tr,
                        hint: 'Enter model',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _colorController,
                        label: 'COLOR'.tr,
                        hint: 'Enter color',
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.sudanWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primaryColor.withOpacity(0.4),
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
                          isUpdateMode ? 'UPDATE_LOST_CAR'.tr : 'ADD_LOST_CAR'.tr,
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

  Widget _buildDividerWithLabel(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
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
        filled: true,
        fillColor: Colors.grey.shade50,
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

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LAST_KNOWN_LOCATION'.tr + ' *',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final result = await Get.to(
              () => LocationPickerView(
                initialLatitude: _selectedLatitude,
                initialLongitude: _selectedLongitude,
              ),
            );

            if (result != null) {
              setState(() {
                _selectedLatitude = result['latitude'];
                _selectedLongitude = result['longitude'];
                _locationController.text = result['address'] ?? '';
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _locationController.text.isEmpty
                        ? 'Tap to pick location'
                        : _locationController.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: _locationController.text.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                  ),
                ),
                const Icon(Icons.location_on, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_locationController.text.isEmpty || _selectedLatitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location'.tr),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = Get.find<MissingCarViewModel>();
      bool success;

      if (isUpdateMode) {
        // Update mode
        success = await viewModel.updateMissingCar(
          carId: widget.car!.id,
          plateNumber: _plateNumberController.text.trim(),
          chassisNumber: _chassisNumberController.text.trim(),
          brand: widget.car!.brand, // Keep original brand (not sent to API)
          model: _modelController.text.trim(),
          color: _colorController.text.trim(),
          description: widget.car!.description, // Keep original description (not sent to API)
          lastKnownLocation: _locationController.text.trim(),
          contactInfo: widget.car!.contactInfo, // Keep original contactInfo (not sent to API)
          status: widget.car!.status, // Keep original status (not sent to API)
          rewardAmount: widget.car!.rewardAmount, // Keep original rewardAmount (not sent to API)
          imageFile: null, // Image not supported by API
        );
      } else {
        // Create mode
        success = await viewModel.createLostCarRequest(
          plateNumber: _plateNumberController.text.trim(),
          chassisNumber: _chassisNumberController.text.trim(),
          model: _modelController.text.trim(),
          color: _colorController.text.trim(),
          lastKnownLocation: _locationController.text.trim(),
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.sudanWhite),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUpdateMode
                          ? 'LOST_CAR_UPDATE_SUCCESS'.tr
                          : 'LOST_CAR_ADD_SUCCESS'.tr,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.secondaryColor,
              behavior: SnackBarBehavior.fixed,
            ),
          );
          Get.back(result: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: AppTheme.sudanWhite),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUpdateMode
                          ? 'LOST_CAR_UPDATE_ERROR'.tr
                          : 'LOST_CAR_ADD_ERROR'.tr,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.fixed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: AppTheme.sudanWhite),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isUpdateMode
                        ? 'LOST_CAR_UPDATE_ERROR'.tr
                        : 'LOST_CAR_ADD_ERROR'.tr,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
