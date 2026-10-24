import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LicenseStorage {
  static const String _fileName = 'shopmanager.license';
  static const String _tempFileName = 'shopmanager.license.tmp';

  final Directory? _baseDirectoryOverride;

  LicenseStorage([this._baseDirectoryOverride]);

  Future<File> _getFile(String name) async {
    final dir = _baseDirectoryOverride ?? await getApplicationSupportDirectory();
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}${Platform.pathSeparator}$name');
  }

  /// Reads the saved license token from internal storage, or null if missing.
  Future<String?> readLicenseToken() async {
    try {
      final file = await _getFile(_fileName);
      if (!file.existsSync()) return null;
      final content = await file.readAsString();
      final trimmed = content.trim();
      return trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }

  /// Atomically writes the verified license token to internal storage via a temp file.
  Future<void> writeLicenseToken(String token) async {
    final tempFile = await _getFile(_tempFileName);
    final targetFile = await _getFile(_fileName);

    if (tempFile.existsSync()) {
      await tempFile.delete();
    }

    // Write to temp file and flush to disk
    await tempFile.writeAsString(token.trim(), flush: true);

    // Atomic rename
    await tempFile.rename(targetFile.path);
  }

  /// Checks if the license file exists.
  Future<bool> hasLicenseFile() async {
    final file = await _getFile(_fileName);
    return file.existsSync();
  }

  /// Removes the license file (strictly for testing).
  Future<void> deleteLicenseFile() async {
    final file = await _getFile(_fileName);
    if (file.existsSync()) {
      await file.delete();
    }
    final temp = await _getFile(_tempFileName);
    if (temp.existsSync()) {
      await temp.delete();
    }
  }
}
