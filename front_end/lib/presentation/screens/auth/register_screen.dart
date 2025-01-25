import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/googleFonts.dart';
import '../../../core/config/theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('Registration State: $state');
        if (state is AuthAuthenticated) {
          print('Navigating to main screen');
          Navigator.pushReplacementNamed(context, '/main');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white),
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/welcome'),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Create\nAccount',
                          style: AppTheme.headingLarge.copyWith(
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up to get started',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 48),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _firstNameController,
                                    enabled: state is! AuthLoading,
                                    style: AppTheme.bodyLarge
                                        .copyWith(color: Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      hintText: 'Enter your first name',
                                      prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppTheme.primaryColor),
                                      labelStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[700]),
                                      hintStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[400]),
                                      helperText: 'Enter your legal first name',
                                      helperStyle: AppTheme.bodySmall
                                          .copyWith(color: Colors.grey[600]),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your first name';
                                      }
                                      if (value.length < 2) {
                                        return 'First name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _lastNameController,
                                    enabled: state is! AuthLoading,
                                    style: AppTheme.bodyLarge
                                        .copyWith(color: Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      hintText: 'Enter your last name',
                                      prefixIcon: const Icon(
                                          Icons.person_outline,
                                          color: AppTheme.primaryColor),
                                      labelStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[700]),
                                      hintStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[400]),
                                      helperText: 'Enter your legal last name',
                                      helperStyle: AppTheme.bodySmall
                                          .copyWith(color: Colors.grey[600]),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your last name';
                                      }
                                      if (value.length < 2) {
                                        return 'Last name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    enabled: state is! AuthLoading,
                                    keyboardType: TextInputType.emailAddress,
                                    style: AppTheme.bodyLarge
                                        .copyWith(color: Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email',
                                      prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: AppTheme.primaryColor),
                                      labelStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[700]),
                                      hintStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[400]),
                                      helperText:
                                          'Use a valid email address (e.g., name@example.com)',
                                      helperStyle: AppTheme.bodySmall
                                          .copyWith(color: Colors.grey[600]),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    enabled: state is! AuthLoading,
                                    obscureText: _obscurePassword,
                                    style: AppTheme.bodyLarge
                                        .copyWith(color: Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(Icons.lock_outline,
                                          color: AppTheme.primaryColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: AppTheme.primaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      labelStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[700]),
                                      hintStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[400]),
                                      helperText: 'At least 6 characters',
                                      helperStyle: AppTheme.bodySmall
                                          .copyWith(color: Colors.grey[600]),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    enabled: state is! AuthLoading,
                                    obscureText: _obscureConfirmPassword,
                                    style: AppTheme.bodyLarge
                                        .copyWith(color: Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      hintText: 'Confirm your password',
                                      prefixIcon: const Icon(Icons.lock_outline,
                                          color: AppTheme.primaryColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: AppTheme.primaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      labelStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[700]),
                                      hintStyle: AppTheme.bodyMedium
                                          .copyWith(color: Colors.grey[400]),
                                      helperText:
                                          'Re-enter your password to confirm',
                                      helperStyle: AppTheme.bodySmall
                                          .copyWith(color: Colors.grey[600]),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm your password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state is AuthLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // Check if passwords match
                                                if (_passwordController.text !=
                                                    _confirmPasswordController
                                                        .text) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Passwords do not match',
                                                        style: AppTheme.bodyMedium
                                                            .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                context.read<AuthBloc>().add(
                                                      AuthRegisterRequested(
                                                        firstName:
                                                            _firstNameController
                                                                .text
                                                                .trim(),
                                                        lastName:
                                                            _lastNameController
                                                                .text
                                                                .trim(),
                                                        email:
                                                            _emailController.text
                                                                .trim(),
                                                        password:
                                                            _passwordController
                                                                .text,
                                                        password2:
                                                            _confirmPasswordController
                                                                .text,
                                                      ),
                                                    );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppTheme.primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: state is AuthLoading
                                          ? const CircularProgressIndicator(
                                              color: AppTheme.primaryColor,
                                            )
                                          : Text(
                                              'Register',
                                              style: AppTheme.bodyLarge.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, '/login'),
                              child: Text(
                                'Login',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthFailure) {
                  return Positioned(
                    top: MediaQuery.of(context).size.height * 0.1,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.error,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.red.shade700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            onPressed: () {
                              // Trigger a rebuild to hide the error
                              context
                                  .read<AuthBloc>()
                                  .add(AuthCheckRequested());
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
