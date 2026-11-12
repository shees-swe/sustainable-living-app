import 'package:drift/drift.dart';

class CommunityJournalPosts extends Table {
  TextColumn get postId => text()();

  TextColumn get title => text()();

  TextColumn get body => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {postId};
}
