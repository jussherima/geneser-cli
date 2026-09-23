{{#with_feed}}import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:{{project_name}}/src/features/feed/data/feed_repository.dart';
part 'feed_service.g.dart';

class FeedService {
  Ref ref;
  FeedService(this.ref);
  Future<List<String>> fetchFeed() => ref.read(feedRepositoryProvider).fetch();
}

@riverpod
FeedService feedService(Ref ref) => FeedService(ref);

@riverpod
Future<List<String>> feedList(Ref ref) => ref.read(feedServiceProvider).fetchFeed();{{/with_feed}}{{^with_feed}}// disabled{{/with_feed}}
