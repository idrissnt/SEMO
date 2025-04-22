import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/widgets/shared/form_validators.dart';

/// A form widget for the registration screen
class RegisterFormWidget extends StatefulWidget {
  final AuthBloc? authBloc;

  const RegisterFormWidget({Key? key, this.authBloc}) : super(key: key);

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final AppLogger _logger = AppLogger();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      _logger.info('Registration attempt for email: $email');

      try {
        // Use the provided bloc or get it from context
        final authBloc = widget.authBloc ?? context.read<AuthBloc>();
        authBloc.add(
          AuthRegisterRequested(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
          ),
        );
      } catch (e, stackTrace) {
        _logger.error('Registration error', error: e, stackTrace: stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } else {
      _logger.warning('Registration form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: widget.authBloc,
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                enabled: state is! AuthLoading,
                style: context.bodyLarge.copyWith(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  prefixIcon:
                      Icon(Icons.person_outline, color: context.primaryColor),
                  labelStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[700]),
                  hintStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[400]),
                  helperText: 'Enter your legal first name',
                  helperStyle:
                      context.bodySmall.copyWith(color: Colors.grey[600]),
                ),
                validator: (value) =>
                    FormValidators.validateName(value, 'First name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                enabled: state is! AuthLoading,
                style: context.bodyLarge.copyWith(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  prefixIcon:
                      Icon(Icons.person_outline, color: context.primaryColor),
                  labelStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[700]),
                  hintStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[400]),
                  helperText: 'Enter your legal last name',
                  helperStyle:
                      context.bodySmall.copyWith(color: Colors.grey[600]),
                ),
                validator: (value) =>
                    FormValidators.validateName(value, 'Last name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: state is! AuthLoading,
                style: context.bodyLarge.copyWith(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: context.primaryColor),
                  labelStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[700]),
                  hintStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[400]),
                  helperText: 'We\'ll send a verification email',
                  helperStyle:
                      context.bodySmall.copyWith(color: Colors.grey[600]),
                ),
                validator: FormValidators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: state is! AuthLoading,
                style: context.bodyLarge.copyWith(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Create a password',
                  prefixIcon:
                      Icon(Icons.lock_outline, color: context.primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: context.primaryColor,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  labelStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[700]),
                  hintStyle:
                      context.bodyMedium.copyWith(color: Colors.grey[400]),
                  helperText: 'At least 6 characters with letters and numbers',
                  helperStyle:
                      context.bodySmall.copyWith(color: Colors.grey[600]),
                ),
                validator: FormValidators.validatePassword,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state is AuthLoading ? null : _submitForm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: context.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
