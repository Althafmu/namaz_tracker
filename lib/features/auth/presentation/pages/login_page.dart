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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onLogin() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final validationError = AuthInputValidation.validateLogin(
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
      LoginRequested(email: email, password: password),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => curr.status == AuthStatus.error,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Login Failed'),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 5),
            ),
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text('Welcome Back!', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Log in to continue your prayer streak.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                NeoTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                ),
                const SizedBox(height: 24),
                NeoTextField(
                  label: 'Password',
                  hint: 'Enter your password',
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
                        text: 'Login',
                        color: AppColors.of(context).primary,
                        onPressed: _onLogin,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => context.push('/password-reset'),
                    child: Text(
                      'Forgot Password? Reset it',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.of(context).textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: Text(
                      'Don\'t have an account? Sign Up',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
