import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/neo_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailVerificationPendingPage extends StatelessWidget {
  const EmailVerificationPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => curr.status == AuthStatus.authenticated,
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/');
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      child: Icon(Icons.mark_email_unread_outlined, size: 56, color: c.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Verify Your Email',
                  style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'ve sent a verification link to your email address. Please check your inbox and click the link to continue.',
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
                    children: [
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: NeoButton(
                          text: 'I\'ve Verified My Email',
                          color: c.primary,
                          onPressed: () {
                            // In a real app we might poll or check status, 
                            // here we can trigger an init auth to load config if verified
                            context.read<AuthBloc>().add(InitAuthRequested());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      context.go('/login');
                    },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
