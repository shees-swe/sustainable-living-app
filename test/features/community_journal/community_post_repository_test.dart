import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/community_journal/data/community_post_repository.dart';

void main() {
  late AppDatabase database;
  late CommunityPostRepository repository;
  var currentTime = DateTime.utc(2026, 11, 12);

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    currentTime = DateTime.utc(2026, 11, 12);
    repository = CommunityPostRepository(
      database: database,
      clock: () => currentTime,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('persists posts newest first for a fresh repository read', () async {
    await repository.addPost(
      title: 'First effort',
      body: 'I repaired a lamp instead of replacing it.',
    );
    currentTime = currentTime.add(const Duration(minutes: 1));
    await repository.addPost(
      title: 'Latest effort',
      body: 'I brought a reusable cup.',
    );

    final freshRepository = CommunityPostRepository(database: database);
    final posts = await freshRepository.readPosts();

    expect(posts.map((post) => post.title), ['Latest effort', 'First effort']);
    expect(posts.first.createdAt.toUtc(), DateTime.utc(2026, 11, 12, 0, 1));
    expect(posts.last.body, 'I repaired a lamp instead of replacing it.');
  });

  test('edits and deletes a post', () async {
    await repository.addPost(title: 'Old title', body: 'Old text');
    final original = (await repository.readPosts()).single;

    await repository.editPost(
      postId: original.postId,
      title: 'New title',
      body: 'New text',
    );

    final updated = (await repository.readPosts()).single;
    expect(updated.title, 'New title');
    expect(updated.body, 'New text');
    expect(updated.createdAt, original.createdAt);

    await repository.deletePost(original.postId);
    expect(await repository.readPosts(), isEmpty);
  });

  test('rejects posts with a blank title or body', () async {
    await expectLater(
      repository.addPost(title: ' ', body: 'A post body'),
      throwsArgumentError,
    );
    await expectLater(
      repository.addPost(title: 'A title', body: ' '),
      throwsArgumentError,
    );
    expect(await repository.readPosts(), isEmpty);
  });
}
