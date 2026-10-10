import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/enums.dart';
import '../../../../shared/data/models/user_model.dart';
import '../controllers/users_controller.dart';
import '../repositories/users_repository.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UsersController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controller
    final repository = UsersRepository(Supabase.instance.client);
    _controller = UsersController(repository);

    // Fetch initial data
    _controller.fetchUsersByRole(UserRole.customer);

    // Load data when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadDataForCurrentTab();
      }
    });
  }

  void _loadDataForCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _controller.fetchUsersByRole(UserRole.customer);
        break;
      case 1:
        _controller.fetchUsersByRole(UserRole.dealer);
        break;
      case 2:
        _controller.fetchUsersByRole(UserRole.plumber);
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Users Management',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadDataForCurrentTab,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Customers'),
              Tab(text: 'Dealers'),
              Tab(text: 'Plumbers'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildUsersList(UserRole.customer),
            _buildUsersList(UserRole.dealer),
            _buildUsersList(UserRole.plumber),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddUserDialog(),
          backgroundColor: context.colors.blue,
          icon: const Icon(Icons.person_add),
          label: const Text('Add User'),
        ),
      ),
    );
  }

  Widget _buildUsersList(UserRole role) {
    return Consumer<UsersController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchUsersByRole(role),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<UserModel> users;
        switch (role) {
          case UserRole.customer:
            users = controller.customers;
            break;
          case UserRole.dealer:
            users = controller.dealers;
            break;
          case UserRole.plumber:
            users = controller.plumbers;
            break;
          default:
            users = [];
        }

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  role == UserRole.customer
                      ? Icons.person_outline
                      : role == UserRole.dealer
                          ? Icons.business_outlined
                          : Icons.build_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${role.name}s found',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(user, role);
          },
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user, UserRole role) {
    final isActive = user.isActive;

    // Format date
    final joinedDate = '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}';

    // Determine credit days for dealers
    int? creditDays;
    if (role == UserRole.dealer) {
      if (user.credit90DaysEnabled) {
        creditDays = 90;
      } else if (user.credit30DaysEnabled) {
        creditDays = 30;
      } else {
        creditDays = 0;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  role == UserRole.customer
                      ? Icons.person_outline
                      : role == UserRole.dealer
                          ? Icons.business_outlined
                          : Icons.build_outlined,
                  color: const Color(0xFF666666),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName ?? 'No name',
                            style: context.typography.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF50C878).withOpacity(0.1)
                                : const Color(0xFFE74C3C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: context.typography.bodySmall?.copyWith(
                              color: isActive
                                  ? const Color(0xFF50C878)
                                  : const Color(0xFFE74C3C),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phoneNumber,
                      style: context.typography.bodySmall?.copyWith(
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Joined',
                      style: context.typography.bodySmall?.copyWith(
                        color: const Color(0xFF999999),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      joinedDate,
                      style: context.typography.bodySmall?.copyWith(
                        color: const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (role == UserRole.dealer && creditDays != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit Days',
                        style: context.typography.bodySmall?.copyWith(
                          color: const Color(0xFF999999),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        creditDays > 0 ? '$creditDays days' : 'No credit',
                        style: context.typography.bodySmall?.copyWith(
                          color: const Color(0xFF9B59B6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: context.colors.blue,
                    onPressed: () => _showEditDialog(user, role),
                  ),
                  IconButton(
                    icon: Icon(
                      isActive ? Icons.block : Icons.check_circle_outline,
                      size: 20,
                    ),
                    color: isActive
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFF50C878),
                    onPressed: () => _toggleUserStatus(user, role),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(UserModel user, UserRole role) {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final emailController = TextEditingController(text: user.email);

    // Determine current credit days for dealers
    int? currentCreditDays;
    if (role == UserRole.dealer) {
      if (user.credit90DaysEnabled) {
        currentCreditDays = 90;
      } else if (user.credit30DaysEnabled) {
        currentCreditDays = 30;
      } else {
        currentCreditDays = 0;
      }
    }

    int? selectedCreditDays = currentCreditDays;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Edit ${user.fullName ?? "User"}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (role == UserRole.dealer) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Credit Days',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedCreditDays,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('No Credit')),
                            DropdownMenuItem(value: 30, child: Text('30 Days')),
                            DropdownMenuItem(value: 90, child: Text('90 Days')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCreditDays = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          final controller = _controller;
                          Navigator.pop(context);

                          final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Updating user...')),
                          );

                          final success = await controller.updateUser(
                            user.id,
                            role,
                            fullName: nameController.text.trim(),
                            phoneNumber: phoneController.text.trim(),
                            email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                            creditDays: selectedCreditDays,
                          );

                          scaffoldMessenger.clearSnackBars();

                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('✅ User updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('❌ Failed to update user'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: context.colors.blue,
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleUserStatus(UserModel user, UserRole role) {
    final isActive = user.isActive;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isActive ? 'Deactivate User?' : 'Activate User?',
        ),
        content: Text(
          isActive
              ? 'This user will not be able to login.'
              : 'This user will be able to login again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF50C878),
            ),
            onPressed: () async {
              final controller = _controller;
              Navigator.pop(context);

              final scaffoldMessenger = ScaffoldMessenger.of(this.context);
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text(isActive ? 'Deactivating user...' : 'Activating user...')),
              );

              final success = await controller.toggleUserStatus(
                user.id,
                role,
                !isActive,
              );

              scaffoldMessenger.clearSnackBars();

              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(isActive ? '✅ User deactivated' : '✅ User activated'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('❌ Failed to update user status'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();

    // Get current tab role
    UserRole selectedRole;
    switch (_tabController.index) {
      case 0:
        selectedRole = UserRole.customer;
        break;
      case 1:
        selectedRole = UserRole.dealer;
        break;
      case 2:
        selectedRole = UserRole.plumber;
        break;
      default:
        selectedRole = UserRole.customer;
    }

    int? selectedCreditDays = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add New ${selectedRole.name.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                          prefixText: '+91 ',
                        ),
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        controller: addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                              controller: cityController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'State',
                                border: OutlineInputBorder(),
                              ),
                              controller: stateController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          border: OutlineInputBorder(),
                        ),
                        controller: pincodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      if (selectedRole == UserRole.dealer) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Credit Days',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedCreditDays,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('No Credit')),
                            DropdownMenuItem(value: 30, child: Text('30 Days')),
                            DropdownMenuItem(value: 90, child: Text('90 Days')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCreditDays = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (phoneController.text.trim().length != 10) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid 10-digit phone number'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final controller = _controller;
                          Navigator.pop(context);

                          final scaffoldMessenger = ScaffoldMessenger.of(this.context);
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Creating user...')),
                          );

                          final success = await controller.createUser(
                            phoneNumber: '+91${phoneController.text.trim()}',
                            role: selectedRole,
                            fullName: nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                            email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                            address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                            city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
                            state: stateController.text.trim().isEmpty ? null : stateController.text.trim(),
                            pincode: pincodeController.text.trim().isEmpty ? null : pincodeController.text.trim(),
                            creditDays: selectedCreditDays,
                          );

                          scaffoldMessenger.clearSnackBars();

                          if (success) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('✅ User created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('❌ Failed to create user'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: context.colors.blue,
                        ),
                        child: const Text('Create User'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
