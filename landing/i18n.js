/* HanaNote Landing Page — i18n */
const T = {
  zh: {
    heroTitle: '花笺',
    heroTagline: '隐私至上的 HRT 健康记录',
    heroDesc: '一个温暖、安全的私人健康日记空间。记录服药、追踪血检、模拟药代动力学，所有数据完全本地加密。',
    heroCta: '下载 Android 版',
    heroWebCta: '打开 Web 版',
    featuresTitle: '核心功能',
    feat1Title: '服药管理', feat1Desc: '智能倒计时、剂量转换、库存预警，让每一次服药都安心有序。',
    feat2Title: '血检追踪', feat2Desc: '记录激素面板，WPATH 目标范围指示，趋势图一目了然。',
    feat3Title: 'PK 模拟器', feat3Desc: '双引擎药代动力学模拟，支持 7 种药物制剂，MAP 校准。',
    feat4Title: '加密照片', feat4Desc: '端到端加密的照片日记，AES-256-GCM 保护你的每一张记录。',
    feat5Title: '心情日记', feat5Desc: '每日心情标签、自由文字记录，陪你走过 HRT 旅程的每一天。',
    feat6Title: '时间轴', feat6Desc: '跨功能时间线视图，HRT 里程碑庆祝，见证你的每一步成长。',
    privacyTitle: '隐私，是承诺',
    privacyStat1: '遥测数据', privacyStat2: '端到端加密', privacyStat3: '离线运行',
    privacyDesc: '没有服务器，没有追踪，没有广告。你的健康数据只属于你自己。',
    downloadTitle: '开始你的旅程',
    downloadCta: '下载 HanaNote',
    downloadNote: 'Android 5.0+ | 完全免费 | 开源',
    footerPrivacy: '隐私政策', footerTerms: '使用条款', footerGithub: 'GitHub',
  },
  en: {
    heroTitle: 'HanaNote',
    heroTagline: 'Privacy-first HRT health tracker',
    heroDesc: 'A warm, secure personal health diary. Track medications, monitor blood tests, simulate pharmacokinetics — all data encrypted locally.',
    heroCta: 'Download for Android',
    heroWebCta: 'Open Web App',
    featuresTitle: 'Features',
    feat1Title: 'Medication', feat1Desc: 'Smart countdown timers, dose conversion, inventory alerts. Every dose, on time.',
    feat2Title: 'Blood Tests', feat2Desc: 'Log hormone panels with WPATH target ranges and visual trend charts.',
    feat3Title: 'PK Simulator', feat3Desc: 'Dual-engine pharmacokinetic modeling for 7 drug preparations with MAP calibration.',
    feat4Title: 'Encrypted Photos', feat4Desc: 'End-to-end encrypted photo journal. AES-256-GCM protects every image.',
    feat5Title: 'Mood Journal', feat5Desc: 'Daily mood tags and free-form entries to accompany your HRT journey.',
    feat6Title: 'Timeline', feat6Desc: 'Cross-feature chronological view with HRT milestone celebrations.',
    privacyTitle: 'Privacy is a promise',
    privacyStat1: 'Telemetry', privacyStat2: 'E2E Encryption', privacyStat3: 'Offline',
    privacyDesc: 'No servers. No tracking. No ads. Your health data belongs only to you.',
    downloadTitle: 'Start your journey',
    downloadCta: 'Download HanaNote',
    downloadNote: 'Android 5.0+ | Free | Open Source',
    footerPrivacy: 'Privacy Policy', footerTerms: 'Terms of Use', footerGithub: 'GitHub',
  },
  ja: {
    heroTitle: '花笺',
    heroTagline: 'プライバシー重視のHRT健康記録',
    heroDesc: '温かく安全なプライベート健康日記。服薬記録、血液検査追跡、薬物動態シミュレーション。すべてのデータはローカルで暗号化。',
    heroCta: 'Android版をダウンロード',
    heroWebCta: 'Web版を開く',
    featuresTitle: '主な機能',
    feat1Title: '服薬管理', feat1Desc: 'スマートカウントダウン、用量換算、在庫アラートで、確実な服薬を。',
    feat2Title: '血液検査', feat2Desc: 'ホルモンパネルを記録。WPATH目標範囲とトレンドチャート。',
    feat3Title: 'PKシミュレータ', feat3Desc: '7種類の薬剤製剤に対応したデュアルエンジン薬物動態モデリング。',
    feat4Title: '暗号化写真', feat4Desc: 'エンドツーエンド暗号化のフォトジャーナル。AES-256-GCMで保護。',
    feat5Title: '気分日記', feat5Desc: '毎日の気分タグと自由テキストで、HRTの旅に寄り添います。',
    feat6Title: 'タイムライン', feat6Desc: '機能横断的な時系列ビューとHRTマイルストーンのお祝い。',
    privacyTitle: 'プライバシーは約束',
    privacyStat1: 'テレメトリー', privacyStat2: 'E2E暗号化', privacyStat3: 'オフライン',
    privacyDesc: 'サーバーなし。追跡なし。広告なし。健康データはあなただけのもの。',
    downloadTitle: '旅を始めよう',
    downloadCta: 'HanaNoteをダウンロード',
    downloadNote: 'Android 5.0+ | 完全無料 | オープンソース',
    footerPrivacy: 'プライバシーポリシー', footerTerms: '利用規約', footerGithub: 'GitHub',
  },
};

function detectLang() {
  const saved = localStorage.getItem('hananote_lp_lang');
  if (saved && T[saved]) return saved;
  const nav = (navigator.language || '').toLowerCase();
  if (nav.startsWith('ja')) return 'ja';
  if (nav.startsWith('zh')) return 'zh';
  return 'en';
}

function applyLang(lang) {
  localStorage.setItem('hananote_lp_lang', lang);
  document.documentElement.lang = lang;
  const dict = T[lang] || T.en;
  document.querySelectorAll('[data-i18n]').forEach(function (el) {
    var key = el.getAttribute('data-i18n');
    if (dict[key]) el.textContent = dict[key];
  });
  document.querySelectorAll('.lang-btn').forEach(function (btn) {
    btn.classList.toggle('active', btn.getAttribute('data-lang') === lang);
  });
}

// Init
var currentLang = detectLang();
applyLang(currentLang);

// Language buttons
document.querySelectorAll('.lang-btn').forEach(function (btn) {
  btn.addEventListener('click', function () {
    applyLang(btn.getAttribute('data-lang'));
  });
});
