import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../services/car_api_service.dart';
import 'location_picker_view.dart';

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

  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  double? _selectedLatitude;
  double? _selectedLongitude;

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
              _buildDividerWithLabel('CAR_IMAGES'.tr),
              const SizedBox(height: 12),
              _buildImageUploadSection(),
              const SizedBox(height: 24),

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
                        hint: 'Enter plate number (optional)',
                        required: false,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _chassisNumberController,
                        label: 'CHASSIS_NUMBER'.tr,
                        hint: 'Enter chassis number (optional)',
                        required: true,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _brandController,
                              label: 'BRAND'.tr,
                              hint: 'مثال: تويوتا',
                              required: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _modelController,
                              label: 'MODEL'.tr,
                              hint: 'مثال: كورولا',
                              required: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildLocationField(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildDividerWithLabel('CAR_CONDITION'.tr),
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
                  child: _buildTextField(
                    controller: _conditionDescriptionController,
                    label: 'CONDITION_DESCRIPTION'.tr,
                    hint: 'ENTER_CONDITION_DETAILS'.tr,
                    required: false,
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCarReport,
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

  // ---------- UI HELPERS ----------

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
          'LOCATION'.tr + ' *',
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

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          color: Colors.grey.shade100,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UPLOAD_IMAGES'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select a photo',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => _showImageSourceDialog(context),
                        tooltip: 'Change Image',
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _showImageSourceDialog(BuildContext dialogContext) async {
    showModalBottomSheet(
      context: dialogContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                ),
                Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text('TAKE_PHOTO'.tr),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text('SELECT_FROM_GALLERY'.tr),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Remove Current Image',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- LOGIC ----------

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request appropriate permissions
      bool permissionGranted = false;
      if (source == ImageSource.camera) {
        permissionGranted = await _requestPermission(Permission.camera);
      } else {
        if (await Permission.photos.status.isGranted ||
            await Permission.storage.status.isGranted) {
          permissionGranted = true;
        } else {
          // Request permission based on Android version
          if (await Permission.photos.request().isGranted ||
              await Permission.storage.request().isGranted) {
            permissionGranted = true;
          }
        }
      }

      if (!permissionGranted && source == ImageSource.gallery) {
        // For gallery, we'll still try as some Android versions handle this differently
        permissionGranted = true;
      }

      if (!permissionGranted && source == ImageSource.camera) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please grant camera permission in settings'.tr),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.fixed,
          ),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image. Please try again.'.tr),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }

  Future<void> _submitCarReport() async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create car report
      await CarApiService.createCar(
        plateNumber: _plateNumberController.text.trim(),
        chassisNumber: _chassisNumberController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        description: _conditionDescriptionController.text.trim(),
        location: _locationController.text.trim(),
        latitude: _selectedLatitude!.toString(),
        longitude: _selectedLongitude!.toString(),
        imageFile: _selectedImage,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.sudanWhite),
              const SizedBox(width: 8),
              Expanded(child: Text('CAR_REPORT_SUCCESS'.tr)),
            ],
          ),
          backgroundColor: AppTheme.secondaryColor,
          behavior: SnackBarBehavior.fixed,
        ),
      );

      _clearForm();
      Get.back();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: AppTheme.sudanWhite),
              const SizedBox(width: 8),
              Expanded(child: Text('CAR_REPORT_ERROR'.tr)),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.fixed,
        ),
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
    _selectedImage = null;
    _selectedLatitude = null;
    _selectedLongitude = null;
  }
}
