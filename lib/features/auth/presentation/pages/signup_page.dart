import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../../../../core/widgets/neo_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/auth_input_validation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onSignup() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final validationError = AuthInputValidation.validateSignup(
      name: name,
      email: email,
      password: password,
    );
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    context.read<AuthBloc>().add(
      RegisterRequested(name: name, email: email, password: password),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.of(context).textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding-psych'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => curr.status == AuthStatus.error,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Signup Failed'),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 5),
            ),
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text('Join Namaz Tracker', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Create an account to track your prayers across devices.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                NeoTextField(
                  label: 'Full Name',
                  hint: 'E.g. Ahmed Ali',
                  controller: _nameController,
                ),
                const SizedBox(height: 24),
                NeoTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                ),
                const SizedBox(height: 24),
                NeoTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 48),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.loading ||
                        state.status == AuthStatus.loadingConfig) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.of(context).primary,
                        ),
                      );
                    }
                    return SizedBox(
                      height: 56,
                      child: NeoButton(
                        text: 'Sign Up',
                        color: AppColors.of(context).primary,
                        onPressed: _onSignup,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Already have an account? Login',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
