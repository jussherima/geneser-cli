import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T) data;
  const AsyncValueWidget({super.key, required this.value, required this.data});
  @override Widget build(BuildContext c) => value.when(data: data, loading: ()=> const Center(child: CircularProgressIndicator()), error: (e,_ )=> Center(child: Text(e.toString())));
}
