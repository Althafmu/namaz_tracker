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

class PasswordResetConfirmPage extends StatefulWidget {
  final String? token;

  const PasswordResetConfirmPage({super.key, this.token});

  @override
  State<PasswordResetConfirmPage> createState() =>
      _PasswordResetConfirmPageState();
}

class _PasswordResetConfirmPageState extends State<PasswordResetConfirmPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  void _onSubmit() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters.'),
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    final token = widget.token ?? '';
    context.read<AuthBloc>().add(
      PasswordResetConfirmed(token: token, newPassword: password),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
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
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            curr.status == AuthStatus.error ||
            curr.status == AuthStatus.authenticated,
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Reset failed'),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
          if (state.status == AuthStatus.authenticated) {
            context.go('/');
          }
        },
        child: SafeArea(
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
                      child: Icon(Icons.lock_person_outlined, size: 56, color: c.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Set New Password',
                  style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Your new password must be unique from those previously used.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: c.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
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
                        label: 'New Password',
                        hint: 'At least 8 characters',
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      NeoTextField(
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        controller: _confirmController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          return SizedBox(
                            height: 56,
                            child: NeoButton(
                              text: 'Reset Password',
                              color: c.primary,
                              onPressed: isLoading ? null : _onSubmit,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
      ),
    );
  }
}
