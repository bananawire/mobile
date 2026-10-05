import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/iam/interfaces/pages/login/login_cubit.dart';
import 'package:mobile/iam/interfaces/widgets/auth_button.dart';
import 'package:mobile/iam/interfaces/widgets/auth_text_field.dart';
import 'package:mobile/shared/interfaces/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.go('/analytics');
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
                  const ClairIcon(size: 80),
                  const SizedBox(height: 48),
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
                          Text(
                            AppLocalizations.of(context)!.login_title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.login_subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AuthTextField(
                            controller: _emailController,
                            label: AppLocalizations.of(context)!.common_email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54, size: 20),
                            validator: (value) {
                              if (value == null || value.isEmpty) return AppLocalizations.of(context)!.login_email_required;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passwordController,
                            label: AppLocalizations.of(context)!.common_password,
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return AppLocalizations.of(context)!.login_password_required;
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          AuthButton(
                            label: AppLocalizations.of(context)!.login_button,
                            isLoading: state.isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<LoginCubit>().signIn(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.white10)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  AppLocalizations.of(context)!.login_or_with,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Colors.white10)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AuthButton(
                            label: AppLocalizations.of(context)!.login_google,
                            isSecondary: true,
                            isLoading: state.isLoading,
                            icon: const GoogleIcon(size: 18),
                            onPressed: () => context.read<LoginCubit>().signInWithGoogle(),
                          ),
                          const SizedBox(height: 32),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: RichText(
                              text: TextSpan(
                                text: AppLocalizations.of(context)!.login_no_account,
                                style: const TextStyle(color: Colors.white54, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.login_register_link,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
