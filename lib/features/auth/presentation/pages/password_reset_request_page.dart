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
  State<PasswordResetRequestPage> createState() =>
      _PasswordResetRequestPageState();
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Distinct Header Area
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: c.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: c.primary.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Icon(Icons.mark_email_read_outlined, size: 56, color: c.primary),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Forgot Password?',
                style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _submitted
                    ? 'We\'ve sent a password reset link to your email. It will expire in 1 hour.'
                    : 'No worries! Enter your email address below and we will send you a link to reset your password.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: c.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (!_submitted) ...[
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: c.textPrimary.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NeoTextField(
                        label: 'Email Address',
                        hint: 'name@example.com',
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
                            setState(() => _submitted = false);
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
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: c.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.primary.withOpacity(0.2), width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: c.primary, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Check your inbox',
                        style: AppTextStyles.headlineMedium.copyWith(color: c.primary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click the link in the email to set a new password.',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new, size: 14, color: c.textPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Login',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
