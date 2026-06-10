import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/iam/interfaces/pages/confirm_registration/confirm_registration_cubit.dart';
import 'package:mobile/iam/interfaces/widgets/auth_button.dart';
import 'package:mobile/iam/interfaces/widgets/auth_text_field.dart';

class ConfirmRegistrationScreen extends StatefulWidget {
  const ConfirmRegistrationScreen({super.key});

  @override
  State<ConfirmRegistrationScreen> createState() => _ConfirmRegistrationScreenState();
}

class _ConfirmRegistrationScreenState extends State<ConfirmRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ConfirmRegistrationCubit, ConfirmRegistrationState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.go('/login');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration confirmed! Please sign in.')),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Verify Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter the verification code sent to your email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthTextField(
                            controller: _codeController,
                            label: 'Verification Code',
                            hint: 'ABCD-1234',
                            textCapitalization: TextCapitalization.characters,
                            prefixIcon: const Icon(Icons.verified_user_outlined, color: Colors.white54, size: 20),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Verification code is required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          AuthButton(
                            label: 'Verify',
                            isLoading: state.isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ConfirmRegistrationCubit>().confirmRegistration(
                                      verificationCode: _codeController.text.trim().toUpperCase(),
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: 32),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
