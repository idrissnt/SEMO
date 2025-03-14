import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:semo/presentation/blocs/auth/auth_bloc.dart';
import 'package:semo/presentation/blocs/auth/auth_event.dart';
import 'package:semo/presentation/widgets/auth/auth_submit_button.dart';
import 'package:semo/presentation/widgets/auth/auth_text_field.dart';
import 'package:semo/presentation/widgets/auth/form_validators.dart';

/// A form widget for the registration screen
class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _firstNameController,
            labelText: 'First Name',
            hintText: 'Enter your first name',
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) => FormValidators.validateName(value, 'First name'),
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _lastNameController,
            labelText: 'Last Name',
            hintText: 'Enter your last name',
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) => FormValidators.validateName(value, 'Last name'),
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: FormValidators.validateEmail,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            obscureText: !_isPasswordVisible,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            validator: FormValidators.validatePassword,
          ),
          const SizedBox(height: 24),
          AuthSubmitButton(
            text: 'Register',
            onPressed: _submitForm,
          ),
        ],
      ),
    );
  }
}
