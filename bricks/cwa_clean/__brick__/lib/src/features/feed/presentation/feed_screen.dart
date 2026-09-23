{{#with_feed}}import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:{{project_name}}/src/common_widgets/async_value_widget.dart';
import 'package:{{project_name}}/src/features/feed/application/feed_service.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final v = ref.watch(feedListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: AsyncValueWidget(value: v, data: (list) => ListView.builder(itemCount: list.length, itemBuilder: (_, i) => ListTile(title: Text(list[i])))),
    );
  }
}{{/with_feed}}{{^with_feed}}import 'package:flutter/material.dart'; class FeedScreen extends StatelessWidget { const FeedScreen({super.key}); @override Widget build(BuildContext c) => const Scaffold(body: Center(child: Text('Feed disabled'))); }{{/with_feed}}
