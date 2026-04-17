import 'dart:io';

import 'package:geneser/geneser.dart';

Future<void> main(List<String> arguments) async {
  final exitCode = await GeneserRunner().run(arguments);
  await stdout.flush();
  exit(exitCode);
}
