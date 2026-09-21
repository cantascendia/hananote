// HanaNote v2 — Sign up page.
// Email + password + opt-in cloud sync toggle (default ON).
// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_card.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_input.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pill_button.dart';
import 'package:hananote/features/cloud_auth/presentation/bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _autoSync = true;

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
      appBar: const HoyoAppBar(title: '注册'),
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
              child: ListView(
                children: [
                  const HoyoEyebrow('Welcome'),
                  const SizedBox(height: 8),
                  Text(
                    '开启你的花笺',
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
                    label: 'PASSWORD · 至少 8 位',
                    controller: _password,
                    hint: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 18),
                  HoyoCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '加密云同步',
                                style: HanaTypography.titleSm.copyWith(
                                  color: HanaColors.primaryOf(context),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '所有数据在你的设备上加密后再上传，'
                                '服务器只存乱码',
                                style: HanaTypography.labelSm.copyWith(
                                  color: HanaColorsV2.goldDeep,
                                  letterSpacing: 0.44,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _autoSync,
                          onChanged: (v) => setState(() => _autoSync = v),
                          activeThumbColor: HanaColorsV2.gold,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  HoyoPillButton(
                    label: '创建账号',
                    icon: Icons.auto_awesome,
                    variant: HoyoPillVariant.gold,
                    expand: true,
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            AuthSignUpEmailRequested(
                              _email.text.trim(),
                              _password.text,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => context.go('/auth/sign-in'),
                    child: const Text('已有账号？登录 →'),
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
