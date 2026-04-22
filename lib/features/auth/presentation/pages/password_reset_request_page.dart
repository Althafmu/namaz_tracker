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

class PasswordResetRequestPage extends StatefulWidget {
  const PasswordResetRequestPage({super.key});

  @override
  State<PasswordResetRequestPage> createState() => _PasswordResetRequestPageState();
}

class _PasswordResetRequestPageState extends State<PasswordResetRequestPage> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  void _onSubmit() {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }
    context.read<AuthBloc>().add(PasswordResetRequested(email: email));
    setState(() => _submitted = true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: c.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                Icons.lock_reset,
                size: 64,
                color: c.primary,
              ),
              const SizedBox(height: 32),
              Text('Reset Password', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 8),
              Text(
                _submitted
                    ? 'Check your email for a reset link. The link expires in 1 hour.'
                    : 'Enter your email and we\'ll send you a reset link.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
              ),
              if (!_submitted) ...[
                const SizedBox(height: 48),
                NeoTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                ),
                const SizedBox(height: 32),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.status == AuthStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage ?? 'Request failed'),
                          backgroundColor: Colors.red.shade700,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state.status == AuthStatus.loading;
                    return SizedBox(
                      height: 56,
                      child: NeoButton(
                        text: 'Send Reset Link',
                        color: c.primary,
                        onPressed: isLoading ? null : _onSubmit,
                      ),
                    );
                  },
                ),
              ] else ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, color: c.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'If an account exists for this email, a reset link was sent.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Remember your password? Login',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}