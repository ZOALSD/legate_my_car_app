import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:legate_my_car/models/enums/account_type.dart';
import 'package:legate_my_car/models/enums/user_status.dart';
import 'package:legate_my_car/models/user_model.dart';
import 'package:legate_my_car/views/user_form_view.dart';

class UserSingleView extends StatefulWidget {
  final UserModel user;

  const UserSingleView({super.key, required this.user});

  @override
  State<UserSingleView> createState() => _UserSingleViewState();
}

class _UserSingleViewState extends State<UserSingleView> {
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd • HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('USER_DETAILS_TITLE'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'UPDATE_USER_TITLE'.tr,
            onPressed: _openEditForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 16),
            _buildDetailTile(
              context: context,
              label: 'EMAIL'.tr,
              value: _user.email,
              icon: Icons.email,
            ),
            _buildDetailTile(
              context: context,
              label: 'STATUS'.tr,
              value: _statusLabel(_user.status),
              icon: Icons.circle,
              iconColor: _statusColor(_user.status.name),
            ),
            _buildDetailTile(
              context: context,
              label: 'ACCOUNT_TYPE'.tr,
              value: _accountTypeLabel(_user.accountType),
              icon: Icons.badge,
            ),
            _buildDetailTile(
              context: context,
              label: 'ACCOUNT_CREATED_AT'.tr,
              value: dateFormat.format(_user.createdAt.toLocal()),
              icon: Icons.calendar_today,
            ),
            _buildDetailTile(
              context: context,
              label: 'ACCOUNT_UPDATED_AT'.tr,
              value: dateFormat.format(_user.updatedAt.toLocal()),
              icon: Icons.update,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditForm() async {
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (_) => UserFormView(user: _user)),
    );

    if (updatedUser != null) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                _user.name.isNotEmpty ? _user.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    Color? iconColor,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (iconColor ?? Theme.of(context).primaryColor)
              .withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
        ),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }

  Color _statusColor(String statusName) {
    switch (statusName) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _statusLabel(UserStatus status) {
    return 'USER_STATUS_${status.name.toUpperCase()}'.tr;
  }

  String _accountTypeLabel(AccountType type) {
    return 'USER_ACCOUNT_${type.name.toUpperCase()}'.tr;
  }
}
