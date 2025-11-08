import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/models/enums/lost_status.dart';
import 'package:legate_my_car/models/lost_car_model.dart';
import '../viewmodels/missing_car_viewmodel.dart';
import '../theme/app_theme.dart';

class LostCarFormView extends StatefulWidget {
  final LostCarModel? car; // null for create, non-null for update

  const LostCarFormView({super.key, this.car});

  @override
  State<LostCarFormView> createState() => _LostCarFormViewState();
}

class _LostCarFormViewState extends State<LostCarFormView> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _carNameController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _locationController = TextEditingController();

  LostStatus? _selectedStatus;

  bool _isLoading = false;

  bool get isUpdateMode => widget.car != null;

  @override
  void initState() {
    super.initState();
    if (isUpdateMode) {
      // Use addPostFrameCallback to ensure UI is ready before setting text
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateFormFields();
      });
    }
  }

  void _populateFormFields() {
    final lostCar = widget.car!;
    _plateNumberController.text = lostCar.plateNumber ?? '';
    _chassisNumberController.text = lostCar.chassisNumber ?? '';
    _carNameController.text = lostCar.carName ?? '';
    _modelController.text = lostCar.model ?? '';
    _colorController.text = lostCar.color ?? '';
    _phoneNumberController.text = lostCar.phoneNumber ?? '';
    _locationController.text = lostCar.lastKnownLocation ?? '';

    if (mounted) {
      setState(() {
        _selectedStatus = lostCar.status;
      });
    } else {
      _selectedStatus = lostCar.status;
    }
  }

  LostCarModel get lostCar => LostCarModel(
    id: widget.car?.id,
    requestNumber: widget.car?.requestNumber,
    plateNumber: _plateNumberController.text.trim(),
    chassisNumber: _chassisNumberController.text.trim(),
    carName: _carNameController.text.trim(),
    model: _modelController.text.trim(),
    color: _colorController.text.trim(),
    lastKnownLocation: _locationController.text.trim(),
    phoneNumber: _phoneNumberController.text.trim(),
    status: _selectedStatus,
  );

  @override
  void dispose() {
    _plateNumberController.dispose();
    _chassisNumberController.dispose();
    _carNameController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    _selectedStatus = null;
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
                        hint: 'ENTER_PLATE_NUMBER'.tr,
                        required: true,
                        enforceLanguageRule: true,
                        allowDigits: true,
                        extraAllowedCharacters: '- ',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _chassisNumberController,
                        label: 'CHASSIS_NUMBER'.tr,
                        hint: 'ENTER_CHASSIS_NUMBER'.tr,
                        required: true,
                        enforceLanguageRule: true,
                        allowDigits: true,
                        extraAllowedCharacters: '- ',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _carNameController,
                        label: 'CAR_NAME'.tr,
                        hint: 'ENTER_CAR_NAME'.tr,
                        required: true,
                        enforceLanguageRule: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _modelController,
                        label: 'MODEL'.tr,
                        hint: 'ENTER_MODEL'.tr,
                        required: false,
                        enforceLanguageRule: true,
                        allowDigits: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _colorController,
                        label: 'COLOR'.tr,
                        hint: 'ENTER_COLOR'.tr,
                        required: false,
                        enforceLanguageRule: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneNumberController,
                        label: 'PHONE_NUMBER'.tr,
                        hint: 'ENTER_PHONE_NUMBER'.tr,
                        required: true,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _locationController,
                        label: 'LOCATION'.tr,
                        hint: 'ENTER_LOCATION'.tr,
                        required: true,
                        enforceLanguageRule: true,
                        allowDigits: true,
                        extraAllowedCharacters: ',.-/',
                      ),

                      if (isUpdateMode) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              'STATUS'.tr,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<LostStatus>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: LostStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.translatedStatus),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          },
                        ),
                      ],
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
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
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
                          isUpdateMode
                              ? 'UPDATE_LOST_CAR'.tr
                              : 'ADD_LOST_CAR'.tr,
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
    TextInputType keyboardType = TextInputType.text,
    bool enforceLanguageRule = false,
    bool allowDigits = false,
    String extraAllowedCharacters = '',
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
      validator: (value) {
        final input = value?.trim() ?? '';

        if (required && input.isEmpty) {
          return '${'THIS_FIELD_IS_REQUIRED'.tr} ${label.toUpperCase()}';
        }

        if (input.isEmpty) {
          return null;
        }

        if (enforceLanguageRule &&
            !_isArabicOrEnglish(
              input,
              allowDigits: allowDigits,
              extraAllowedCharacters: extraAllowedCharacters,
            )) {
          return 'ARABIC_OR_ENGLISH_ONLY'.tr;
        }

        return null;
      },
      onChanged: (value) {
        _formKey.currentState?.validate();
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
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
        success = await viewModel.updateLostCarRequest(lostCar: lostCar);
      } else {
        // Create mode
        success = await viewModel.createLostCarRequest(lostCar: lostCar);
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
          Get.back(result: success);
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

  bool _isArabicOrEnglish(
    String input, {
    bool allowDigits = false,
    String extraAllowedCharacters = '',
  }) {
    var allowed = r'\u0600-\u06FFa-zA-Z';

    if (allowDigits) {
      allowed += r'0-9';
    }

    if (extraAllowedCharacters.isNotEmpty) {
      final escaped = extraAllowedCharacters
          .split('')
          .map((char) => RegExp.escape(char))
          .join();
      allowed += escaped;
    }

    final buffer = StringBuffer('^[')
      ..write(allowed)
      ..write(r'\s]+$');

    return RegExp(buffer.toString()).hasMatch(input);
  }
}
