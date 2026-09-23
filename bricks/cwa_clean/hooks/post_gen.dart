import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) {
  // dart format generated project
  try {
    Process.runSync('dart', ['format', '.'], workingDirectory: Directory.current.path);
  } catch (_) {}
}
