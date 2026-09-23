import 'package:flutter/material.dart';
class LoaderAdaptative extends StatelessWidget {
  const LoaderAdaptative({super.key});
  @override Widget build(BuildContext context) => const CircularProgressIndicator();
}
class PrimaryButton extends StatelessWidget {
  final String label; final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.label, required this.onPressed});
  @override Widget build(BuildContext c) => FilledButton(onPressed: onPressed, child: Text(label));
}
