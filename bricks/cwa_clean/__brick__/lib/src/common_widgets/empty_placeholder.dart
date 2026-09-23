import 'package:flutter/material.dart';
class EmptyPlaceholder extends StatelessWidget { final String message; const EmptyPlaceholder({super.key, required this.message}); @override Widget build(BuildContext c)=> Center(child: Text(message)); }
