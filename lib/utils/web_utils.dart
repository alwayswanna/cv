import 'dart:js_interop';

@JS('window.printResumeHtml')
external void printResumeHtml(String htmlContent);

@JS('navigator.userAgent')
external String get _userAgent;

bool get isSafari {
  final ua = _userAgent;
  return ua.contains('Safari') && !ua.contains('Chrome') && !ua.contains('Chromium');
}