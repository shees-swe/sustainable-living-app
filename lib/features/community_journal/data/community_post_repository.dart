import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';

class CommunityPostRepository {
  CommunityPostRepository({required this.database, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase database;
  final DateTime Function() _clock;

  Stream<List<CommunityJournalPost>> watchPosts() => _postsQuery().watch();

  Future<List<CommunityJournalPost>> readPosts() => _postsQuery().get();

  Future<void> addPost({required String title, required String body}) async {
    final fields = _validatedFields(title: title, body: body);
    await database
        .into(database.communityJournalPosts)
        .insert(
          CommunityJournalPostsCompanion.insert(
            postId: _newPostId(),
            title: fields.title,
            body: fields.body,
            createdAt: _clock().toUtc(),
          ),
        );
  }

  Future<void> editPost({
    required String postId,
    required String title,
    required String body,
  }) async {
    final fields = _validatedFields(title: title, body: body);
    final updated =
        await (database.update(
          database.communityJournalPosts,
        )..where((post) => post.postId.equals(postId))).write(
          CommunityJournalPostsCompanion(
            title: Value(fields.title),
            body: Value(fields.body),
          ),
        );
    if (updated == 0) throw StateError('The journal post no longer exists.');
  }

  Future<void> deletePost(String postId) async {
    await (database.delete(
      database.communityJournalPosts,
    )..where((post) => post.postId.equals(postId))).go();
  }

  SimpleSelectStatement<$CommunityJournalPostsTable, CommunityJournalPost>
  _postsQuery() => database.select(database.communityJournalPosts)
    ..orderBy([
      (post) => OrderingTerm.desc(post.createdAt),
      (post) => OrderingTerm.asc(post.postId),
    ]);

  _ValidatedPost _validatedFields({
    required String title,
    required String body,
  }) {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Must not be empty.');
    }
    final cleanBody = body.trim();
    if (cleanBody.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Must not be empty.');
    }
    return _ValidatedPost(title: cleanTitle, body: cleanBody);
  }

  String _newPostId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}

class _ValidatedPost {
  const _ValidatedPost({required this.title, required this.body});

  final String title;
  final String body;
}
