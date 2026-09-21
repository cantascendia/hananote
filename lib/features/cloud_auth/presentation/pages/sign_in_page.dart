// HanaNote v2 — Sign in page.
// Email + password + Apple/Google OAuth.
// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_input.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pill_button.dart';
import 'package:hananote/features/cloud_auth/presentation/bloc/auth_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      appBar: const HoyoAppBar(title: '登录'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSignedIn) {
            context.go('/today');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HoyoEyebrow('Welcome back'),
                  const SizedBox(height: 8),
                  Text(
                    '继续你的花笺',
                    style: HanaTypography.headlineLg.copyWith(
                      color: HanaColors.primaryOf(context),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  HoyoInput(
                    label: 'EMAIL',
                    controller: _email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.alternate_email,
                  ),
                  const SizedBox(height: 14),
                  HoyoInput(
                    label: 'PASSWORD',
                    controller: _password,
                    hint: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 22),
                  HoyoPillButton(
                    label: '登录',
                    icon: Icons.login,
                    variant: HoyoPillVariant.gold,
                    expand: true,
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            AuthSignInEmailRequested(
                              _email.text.trim(),
                              _password.text,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: HoyoPillButton(
                          label: 'Apple',
                          icon: Icons.apple,
                          variant: HoyoPillVariant.ghostLight,
                          expand: true,
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(const AuthSignInAppleRequested()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: HoyoPillButton(
                          label: 'Google',
                          icon: Icons.g_mobiledata,
                          variant: HoyoPillVariant.ghostLight,
                          expand: true,
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(const AuthSignInGoogleRequested()),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/auth/sign-up'),
                    child: const Text('没有账号？立即注册 →'),
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
