import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legate_my_car/models/enums/account_type.dart';
import 'package:legate_my_car/models/enums/user_status.dart';
import 'package:legate_my_car/models/user_model.dart';
import 'package:legate_my_car/viewmodels/user_viewmodel.dart';
import 'package:legate_my_car/views/user_single_view.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final UserViewModel viewModel = UserViewModel.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (viewModel.hasMorePages && !viewModel.isLoading) {
        viewModel.loadNextPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('USERS_TITLE'.tr)),
      body: Obx(() {
        if (viewModel.isLoading && viewModel.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage.isNotEmpty && viewModel.users.isEmpty) {
          return _buildErrorState();
        }

        if (viewModel.users.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.refresh(),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.users.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader();
              }

              final UserModel user = viewModel.users[index - 1];
              return _buildUserCard(user);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOTAL_USERS_LABEL'.trParams({
            'count': viewModel.totalUsers.toString(),
          }),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (viewModel.errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              viewModel.errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    final Color statusColor = _statusColor(user.status.name);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          foregroundColor: statusColor,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildChip(
                  label: _statusLabel(user.status),
                  color: statusColor,
                ),
                _buildChip(
                  label: _accountTypeLabel(user.accountType),
                  color: Colors.blueGrey,
                ),
                _buildChip(
                  label: _carsCountLabel(user.carsCount),
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserSingleView(user: user)),
          );
        },
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'NO_USERS_FOUND'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'TRY_ADJUSTING_SEARCH'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'FAILED_TO_LOAD_USERS'.tr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadUsers(page: 1),
              child: Text('RETRY'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String statusName) {
    switch (statusName) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(UserStatus status) {
    return 'USER_STATUS_${status.name.toUpperCase()}'.tr;
  }

  String _accountTypeLabel(AccountType type) {
    return 'USER_ACCOUNT_${type.name.toUpperCase()}'.tr;
  }

  String _carsCountLabel(int count) {
    return 'USER_CARS_COUNT'.trParams({'count': count.toString()});
  }
}
