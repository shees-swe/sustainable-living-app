import '../../../core/data/database/app_database.dart';

enum UserDataDeletionResult { cancelled, deleted }

class UserDataDeleter {
  factory UserDataDeleter({
    required AppDatabase database,
    required Future<void> Function() closeDatabase,
    required Future<void> Function() deleteDatabaseFiles,
    required Future<void> Function() onGuestReset,
  }) => UserDataDeleter._(
    database,
    closeDatabase,
    deleteDatabaseFiles,
    onGuestReset,
  );

  const UserDataDeleter._(
    this._database,
    this._closeDatabase,
    this._deleteDatabaseFiles,
    this._onGuestReset,
  );

  final AppDatabase _database;
  final Future<void> Function() _closeDatabase;
  final Future<void> Function() _deleteDatabaseFiles;
  final Future<void> Function() _onGuestReset;

  Future<UserDataDeletionResult> deleteAllUserData({
    required bool confirmed,
  }) async {
    if (!confirmed) return UserDataDeletionResult.cancelled;

    await _database.clearAllUserData();
    await _closeDatabase();
    await _deleteDatabaseFiles();
    await _onGuestReset();
    return UserDataDeletionResult.deleted;
  }
}
