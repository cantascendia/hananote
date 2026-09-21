import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Whether the platform supports native file I/O.
const bool kHasFileSystem = true;

/// Writes bytes to a file at [relativePath] under app documents.
Future<String> writeFileBytes(
  String relativePath,
  Uint8List bytes,
) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final file = File(p.join(documentsDirectory.path, relativePath));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Reads bytes from a file at [relativePath] under app documents.
Future<Uint8List?> readFileBytes(String relativePath) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final file = File(p.join(documentsDirectory.path, relativePath));
  if (!file.existsSync()) return null;
  return file.readAsBytes();
}

/// Deletes a file at [relativePath] under app documents.
Future<void> deleteFileAt(String relativePath) async {
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final file = File(p.join(documentsDirectory.path, relativePath));
  if (file.existsSync()) file.deleteSync();
}

/// Writes a string to a temp file and returns its path.
Future<String> writeTempFile(String fileName, String content) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsString(content);
  return file.path;
}

/// Writes binary bytes to a temp file and returns its path.
Future<String> writeTempBytes(String fileName, Uint8List bytes) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Deletes a plugin-created capture only when it belongs to the app cache.
Future<void> deleteTemporaryFile(String absolutePath) async {
  final tempDir = await getTemporaryDirectory();
  final candidate = p.normalize(p.absolute(absolutePath));
  final cacheRoot = p.normalize(p.absolute(tempDir.path));
  if (!p.isWithin(cacheRoot, candidate)) return;
  final file = File(candidate);
  if (await file.exists()) await file.delete();
}
