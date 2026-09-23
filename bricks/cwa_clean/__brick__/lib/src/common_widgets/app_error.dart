import 'package:flutter/material.dart';
class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;
  const AppErrorWidget({super.key, required this.error});
  @override Widget build(BuildContext c) => Material(child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size:48, color: Colors.red), const SizedBox(height:16), Text('Une erreur est survenue', style: Theme.of(c).textTheme.titleLarge), const SizedBox(height:8), Text(error.exceptionAsString(), textAlign: TextAlign.center)]))));
}
