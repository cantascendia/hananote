// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

const _key = 'hananote_banner_dismissed';

/// Whether the download banner has been dismissed.
bool isBannerDismissed() {
  return html.window.localStorage[_key] == '1';
}

/// Persist banner dismissal to localStorage.
void setBannerDismissed() {
  html.window.localStorage[_key] = '1';
}
