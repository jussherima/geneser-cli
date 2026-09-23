{{#with_feed}}import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'feed_repository.g.dart';

class FeedRepository {
  Ref ref;
  FeedRepository(this.ref);
  Future<List<String>> fetch() async => ['Post 1', 'Post 2'];
}

@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) => FeedRepository(ref);{{/with_feed}}{{^with_feed}}// feed disabled{{/with_feed}}
