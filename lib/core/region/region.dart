// HanaNote · Region enum + endpoint mapping.
// ignore_for_file: public_member_api_docs

enum Region {
  global('global'),
  cn('cn');

  const Region(this.code);
  final String code;

  /// Display name for UI (Onboarding region selector).
  String localizedLabel(String langCode) {
    switch (this) {
      case Region.global:
        switch (langCode) {
          case 'zh':
            return '全球';
          case 'ja':
            return 'グローバル';
          default:
            return 'Global';
        }
      case Region.cn:
        switch (langCode) {
          case 'zh':
            return '中国大陆（Cloudflare 加速）';
          case 'ja':
            return '中国本土';
          default:
            return 'Mainland China';
        }
    }
  }
}
