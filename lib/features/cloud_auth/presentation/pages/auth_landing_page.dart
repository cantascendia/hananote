// HanaNote v2 — Auth landing page.
// Three-choice screen shown during onboarding step 4:
//   - 立即注册 (sign-up)
//   - 已有账号 (sign-in)
//   - 跳过保持纯本地 (continue local-only)
//
// Privacy promise reinforced inline: "默认本地，按需同步".
// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hananote/app/theme/hana_colors.dart';
import 'package:hananote/app/theme/hana_colors_v2.dart';
import 'package:hananote/app/theme/hana_typography.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_app_bar.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_card.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_eyebrow.dart';
import 'package:hananote/core/widgets/hoyo/hoyo_pill_button.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HanaColors.backgroundOf(context),
      appBar: const HoyoAppBar(title: '云同步'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HoyoEyebrow('Privacy promise'),
              const SizedBox(height: 8),
              Text(
                '默认本地，按需同步',
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
                    Text(
                      '所有上传到云端的数据，会在你的设备上用 PIN 派生密钥端到端加密。'
                      '服务器只存乱码，连我们也读不到。',
                      style: HanaTypography.bodyMd.copyWith(
                        color: HanaColors.onSurfaceOf(context),
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '· 注册账号 → 自动开启加密同步，跨设备访问',
                      style: HanaTypography.labelMd.copyWith(
                        color: HanaColorsV2.goldDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '· 跳过 → 数据永不离开本机（旧承诺保留）',
                      style: HanaTypography.labelMd.copyWith(
                        color: HanaColorsV2.goldDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              HoyoPillButton(
                label: '立即注册',
                icon: Icons.auto_awesome,
                variant: HoyoPillVariant.gold,
                expand: true,
                onPressed: () => context.push('/auth/sign-up'),
              ),
              const SizedBox(height: 10),
              HoyoPillButton(
                label: '已有账号 · 登录',
                icon: Icons.login,
                variant: HoyoPillVariant.primary,
                expand: true,
                onPressed: () => context.push('/auth/sign-in'),
              ),
              const SizedBox(height: 10),
              HoyoPillButton(
                label: '跳过 · 保持纯本地',
                icon: Icons.lock,
                variant: HoyoPillVariant.ghostLight,
                expand: true,
                onPressed: () => context.go('/today'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
