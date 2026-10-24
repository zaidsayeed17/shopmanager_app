import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/db/app_database.dart';

class BackupValidationResult {
  final bool isValid;
  final int? schemaVersion;
  final DateTime? timestamp;
  final String? errorMessage;

  const BackupValidationResult({
    required this.isValid,
    this.schemaVersion,
    this.timestamp,
    this.errorMessage,
  });

  String? get timestampFormatted {
    if (timestamp == null) return null;
    final d = timestamp!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  /// Execute SQLite VACUUM INTO to produce a complete, consistent snapshot of the live database
  Future<File> createBackup() async {
    final now = DateTime.now();
    final timestampStr = now.toIso8601String();
    final versionStr = _db.schemaVersion.toString();

    // Store backup metadata into settings table prior to snapshot
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(key: 'backup_timestamp', value: Value(timestampStr)),
    );
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(key: 'backup_schema_version', value: Value(versionStr)),
    );

    final tempDir = await getTemporaryDirectory();
    final dateFormatted =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final backupFileName = 'shopmanager_backup_$dateFormatted.db';
    final backupFile = File('${tempDir.path}/$backupFileName');

    // Remove file if it already exists in temp
    if (backupFile.existsSync()) {
      await backupFile.delete();
    }

    final safePath = backupFile.path.replaceAll('\\', '/');
    await _db.customStatement("VACUUM INTO '$safePath'");

    return backupFile;
  }

  /// Inspect a SQLite file in read-only mode to validate core tables and read metadata
  Future<BackupValidationResult> validateBackupFile(File file) async {
    if (!file.existsSync()) {
      return const BackupValidationResult(
        isValid: false,
        errorMessage: 'File could not be read',
      );
    }

    Database? readOnlyDb;
    try {
      readOnlyDb = sqlite3.open(file.path, mode: OpenMode.readOnly);

      // 1. Check core tables
      final tableResult = readOnlyDb.select(
        "SELECT name FROM sqlite_master WHERE type='table';",
      );
      final tableNames = tableResult.map((r) => r['name'] as String).toSet();

      final requiredTables = {
        'customers',
        'items',
        'bills',
        'workers',
        'stock_transactions',
      };

      if (!tableNames.containsAll(requiredTables)) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: "This doesn't look like a ShopManager backup file",
        );
      }

      // 2. Read metadata from settings_table if present
      DateTime? timestamp;
      int? schemaVersion;

      if (tableNames.contains('settings_table')) {
        final settingsResult = readOnlyDb.select(
          "SELECT key, value FROM settings_table WHERE key IN ('backup_timestamp', 'backup_schema_version');",
        );
        for (final row in settingsResult) {
          final key = row['key'] as String?;
          final val = row['value'] as String?;
          if (key == 'backup_timestamp' && val != null) {
            timestamp = DateTime.tryParse(val);
          }
          if (key == 'backup_schema_version' && val != null) {
            schemaVersion = int.tryParse(val);
          }
        }
      }

      // Fallback to user_version pragma if schemaVersion not in settings_table
      if (schemaVersion == null) {
        final pragmaResult = readOnlyDb.select('PRAGMA user_version;');
        if (pragmaResult.isNotEmpty) {
          schemaVersion = pragmaResult.first['user_version'] as int?;
        }
      }

      return BackupValidationResult(
        isValid: true,
        schemaVersion: schemaVersion ?? _db.schemaVersion,
        timestamp: timestamp,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: "File could not be read (${e.toString()})",
      );
    } finally {
      readOnlyDb?.dispose();
    }
  }

  /// Close the live database connection and replace the live database file with validatedFile
  Future<void> restoreFromBackup(File validatedFile) async {
    final liveDbFile = await AppDatabase.getDatabaseFile();

    // Close live database connection
    await _db.close();

    // Replace live database file with contents of validatedFile
    if (liveDbFile.existsSync()) {
      await liveDbFile.delete();
    }
    await validatedFile.copy(liveDbFile.path);
  }
}
