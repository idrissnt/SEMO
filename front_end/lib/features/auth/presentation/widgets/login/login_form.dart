import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';

import 'package:semo/features/auth/presentation/widgets/shared/form_validators.dart';

/// A form widget for the login screen
class LoginFormWidget extends StatefulWidget {
  final AuthBloc? authBloc;

  const LoginFormWidget({Key? key, this.authBloc}) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final AppLogger _logger = AppLogger();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
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
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      _logger.info('Login attempt for email: $email');

      // Use the provided bloc or get it from context
      final authBloc = widget.authBloc ?? context.read<AuthBloc>();
      authBloc.add(
        AuthLoginRequested(
          email: email,
          password: password,
        ),
      );
    } else {
      _logger.warning('Login form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder with the provided bloc or from context
    return BlocBuilder<AuthBloc, AuthState>(
      bloc: widget.authBloc,
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enabled: state is! AuthLoading,
                style: TextStyle(
                  fontSize: AppDimensionsWidth.medium,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppColors.primary),
                  labelStyle: TextStyle(
                    fontSize: AppDimensionsWidth.medium,
                    color: Colors.grey[700],
                  ),
                  hintStyle: TextStyle(
                    fontSize: AppDimensionsWidth.medium,
                    color: Colors.grey[400],
                  ),
                ),
                validator: FormValidators.validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: state is! AuthLoading,
                style: TextStyle(
                  fontSize: AppDimensionsWidth.medium,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon:
                      Icon(Icons.lock_outline, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.primary,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  labelStyle: TextStyle(
                    fontSize: AppDimensionsWidth.medium,
                    color: Colors.grey[700],
                  ),
                  hintStyle: TextStyle(
                    fontSize: AppDimensionsWidth.medium,
                    color: Colors.grey[400],
                  ),
                ),
                validator: FormValidators.validatePassword,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password functionality
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
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
                            'Login',
                            style: TextStyle(
                              fontSize: AppDimensionsWidth.medium,
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
