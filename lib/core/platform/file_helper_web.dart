import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// In-memory file storage for web platform.
final Map<String, Uint8List> _webFileStore = {};

/// Whether the platform supports native file I/O.
const bool kHasFileSystem = false;

/// On web, stores bytes in memory keyed by [relativePath].
Future<String> writeFileBytes(
  String relativePath,
  Uint8List bytes,
) async {
  _webFileStore[relativePath] = bytes;
  return relativePath;
}

/// On web, reads bytes from in-memory store.
Future<Uint8List?> readFileBytes(String relativePath) async {
  return _webFileStore[relativePath];
}

/// On web, removes bytes from in-memory store.
Future<void> deleteFileAt(String relativePath) async {
  _webFileStore.remove(relativePath);
}

/// On web, triggers a browser download for the given content.
Future<String> writeTempFile(String fileName, String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return fileName;
}

/// On web, triggers a browser download for the given binary bytes.
Future<String> writeTempBytes(String fileName, Uint8List bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return fileName;
}

/// Browser captures have no application-cache file to remove.
Future<void> deleteTemporaryFile(String absolutePath) async {}
