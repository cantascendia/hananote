// HanaNote v2 — Account / sync status page.
// Shows: email, last sync timestamp, "退出云端" button, and link to
// the destructive "紧急清除" wipe action.
// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_card.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pill_button.dart';
import 'package:hananote/features/cloud_auth/presentation/bloc/auth_bloc.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      appBar: const HoyoAppBar(title: '账号'),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final email = switch (state) {
            AuthSignedIn(:final email) => email ?? '—',
            _ => '未登录',
          };
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HoyoEyebrow('Account'),
                  const SizedBox(height: 8),
                  Text(
                    '云端同步',
                    style: HanaTypography.headlineLg.copyWith(
                      color: HanaColors.primaryOf(context),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  HoyoCard(
                    cornerMark: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Row(label: 'EMAIL', value: email),
                        const SizedBox(height: 12),
                        const _Row(label: 'STATUS', value: '默认本地，已加密同步'),
                        const SizedBox(height: 12),
                        const _Row(
                            label: 'E2EE', value: 'AES-256-GCM · Argon2id'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  HoyoPillButton(
                    label: '退出登录',
                    icon: Icons.logout,
                    variant: HoyoPillVariant.ghostLight,
                    expand: true,
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthSignOutRequested()),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _confirmWipe(context),
                    child: Text(
                      '紧急清除：永久删除云端 + 本地数据',
                      style: HanaTypography.labelMd.copyWith(
                        color: HanaColors.tertiaryOf(context),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.44,
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

  void _confirmWipe(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dCtx) {
        var taps = 0;
        return StatefulBuilder(
          builder: (sCtx, setS) {
            return AlertDialog(
              backgroundColor: HanaColors.surfaceContainerLowestOf(dCtx),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('紧急清除'),
              content: Text(
                '此操作不可恢复：\n'
                '· 删除云端全部加密记录\n'
                '· 删除你的账号\n'
                '· 退出登录\n\n'
                '请连续点击「确认删除」3 次以确认（当前 $taps / 3）',
                style: HanaTypography.bodyMd.copyWith(
                  color: HanaColorsV2.goldDeep,
                  height: 1.7,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dCtx).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    setS(() => taps++);
                    if (taps >= 3) {
                      Navigator.of(dCtx).pop();
                      context
                          .read<AuthBloc>()
                          .add(const AuthWipeAccountRequested());
                    }
                  },
                  child: Text(
                    '确认删除',
                    style: TextStyle(
                      color: HanaColors.tertiaryOf(dCtx),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: HanaTypography.labelSm.copyWith(
              color: HanaColorsV2.goldDeep,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.32,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: HanaTypography.bodyMd.copyWith(
              color: HanaColors.onSurfaceOf(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
