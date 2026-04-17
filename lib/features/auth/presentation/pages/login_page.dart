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
import 'package:get_it/get_it.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../prayer/presentation/bloc/settings/settings_bloc.dart';
import '../../../prayer/presentation/bloc/settings/settings_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Finding #5: Email format regex
  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (email.length > 254 || !_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password.length < 8 || password.length > 128) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be 8-128 characters')),
      );
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
              backgroundColor: AppColors.of(context).primary,
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
                Text('Log in to continue your prayer streak.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.of(context).textSecondary)),
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
                    if (state.status == AuthStatus.loading) {
                      return Center(child: CircularProgressIndicator(color: AppColors.of(context).primary));
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
