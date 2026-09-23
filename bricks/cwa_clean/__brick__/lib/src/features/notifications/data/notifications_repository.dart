{{#with_notifications}}import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'notifications_repository.g.dart';

class NotificationsRepository {
  Ref ref;
  NotificationsRepository(this.ref);
  Future<List<String>> fetch() async => [];
}

@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) => NotificationsRepository(ref);{{/with_notifications}}{{^with_notifications}}// disabled{{/with_notifications}}
