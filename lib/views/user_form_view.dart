import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/models/enums/account_type.dart';
import 'package:legate_my_car/models/enums/user_status.dart';
import 'package:legate_my_car/models/user_model.dart';
import 'package:legate_my_car/viewmodels/user_viewmodel.dart';

class UserFormView extends StatefulWidget {
  final UserModel user;

  const UserFormView({super.key, required this.user});

  @override
  State<UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<UserFormView> {
  final _formKey = GlobalKey<FormState>();
  final UserViewModel _viewModel = UserViewModel.instance;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late UserStatus _selectedStatus;
  late AccountType _selectedAccountType;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedStatus = widget.user.status;
    _selectedAccountType = widget.user.accountType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('UPDATE_USER_TITLE'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'NAME'.tr,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'THIS_FIELD_IS_REQUIRED'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: false,
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'EMAIL'.tr,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'THIS_FIELD_IS_REQUIRED'.tr;
                  }
                  if (!GetUtils.isEmail(value.trim())) {
                    return 'INVALID_EMAIL'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserStatus>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'STATUS'.tr,
                  border: const OutlineInputBorder(),
                ),
                items: UserStatus.values
                    .map(
                      (status) => DropdownMenuItem<UserStatus>(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _selectedStatus = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                initialValue: _selectedAccountType,
                decoration: InputDecoration(
                  labelText: 'ACCOUNT_TYPE'.tr,
                  border: const OutlineInputBorder(),
                ),
                items: AccountType.values
                    .where((type) => type != AccountType.client)
                    .map(
                      (type) => DropdownMenuItem<AccountType>(
                        value: type,
                        child: Text(_accountTypeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _selectedAccountType = value;
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('SAVE_CHANGES'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final updatedUser = await _viewModel.updateUser(
        id: widget.user.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        status: _selectedStatus,
        accountType: _selectedAccountType,
      );

      if (!mounted) return;
      Get.back(result: updatedUser);
      Get.snackbar(
        'SUCCESS'.tr,
        'USER_UPDATE_SUCCESS'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'ERROR'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _statusLabel(UserStatus status) {
    return 'USER_STATUS_${status.name.toUpperCase()}'.tr;
  }

  String _accountTypeLabel(AccountType accountType) {
    return 'USER_ACCOUNT_${accountType.name.toUpperCase()}'.tr;
  }
}
