import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    print('ProfileScreen: Initializing');
    // Check if we're already authenticated
    final currentState = context.read<AuthBloc>().state;
    print('ProfileScreen: Current auth state: $currentState');
    
    if (currentState is! AuthAuthenticated) {
      print('ProfileScreen: Requesting auth check');
      context.read<AuthBloc>().add(AuthCheckRequested());
    } else {
      print('ProfileScreen: Already authenticated as: ${currentState.user.email}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(state),
                  const SizedBox(height: 24),
                  _buildProfileMenu(context),
                ],
              ),
            );
          } else if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AuthFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error Loading Profile',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error,
                    style: AppTheme.bodyMedium.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthCheckRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not Authenticated',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(AuthAuthenticated state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              _getInitials(state.user.firstName, state.user.lastName),
              style: AppTheme.headingLarge.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getFullName(state.user.firstName, state.user.lastName),
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.user.email,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? firstName, String? lastName) {
    String initials = '';
    
    if (firstName != null && firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    
    return initials.isEmpty ? '?' : initials;
  }

  String _getFullName(String? firstName, String? lastName) {
    final parts = <String>[];
    
    if (firstName != null && firstName.isNotEmpty) {
      parts.add(firstName);
    }
    
    if (lastName != null && lastName.isNotEmpty) {
      parts.add(lastName);
    }
    
    return parts.isEmpty ? 'User' : parts.join(' ');
  }

  Widget _buildProfileMenu(BuildContext context) {
    final menuItems = [
      {
        'title': 'My Orders',
        'icon': Icons.shopping_bag_outlined,
        'onTap': () {},
      },
      {
        'title': 'Shipping Addresses',
        'icon': Icons.location_on_outlined,
        'onTap': () {},
      },
      {
        'title': 'Payment Methods',
        'icon': Icons.payment_outlined,
        'onTap': () {},
      },
      {
        'title': 'Settings',
        'icon': Icons.settings_outlined,
        'onTap': () {},
      },
      {
        'title': 'Help & Support',
        'icon': Icons.help_outline,
        'onTap': () {},
      },
      {
        'title': 'Logout',
        'icon': Icons.logout,
        'onTap': () async {
          context.read<AuthBloc>().add(AuthLogoutRequested());
          // Wait a moment for the logout to process
          await Future.delayed(const Duration(milliseconds: 100));
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: AppTheme.primaryColor,
          ),
          title: Text(
            item['title'] as String,
            style: AppTheme.bodyMedium,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: item['onTap'] as void Function(),
        );
      },
    );
  }
}
