import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../models/project_manifest.dart';

/// Read / write `.geneser.yaml` at the root of a generated project.
class ProjectManifestService {
  static const String fileName = '.geneser.yaml';

  /// Returns the parsed manifest, or `null` if the file is missing or invalid.
  ProjectManifest? read(String projectDir) {
    final file = File(p.join(projectDir, fileName));
    if (!file.existsSync()) return null;

    try {
      final source = file.readAsStringSync();
      final doc = loadYaml(source);
      if (doc is! YamlMap) return null;

      final geneser = doc['geneser'];
      if (geneser is! YamlMap) return null;

      final template = geneser['template'];
      final project = geneser['project'];
      if (template is! YamlMap || project is! YamlMap) return null;

      final rawFeatures = geneser['features'];
      final features = rawFeatures is YamlList
          ? rawFeatures.cast<String>().toList()
          : <String>[];

      return ProjectManifest(
        geneserVersion: geneser['version'] as String,
        templateId: template['id'] as String,
        projectName: project['name'] as String,
        organization: project['organization'] as String,
        features: features,
      );
    } on Exception {
      return null;
    }
  }

  /// Serialize [manifest] to disk at `<projectDir>/.geneser.yaml`.
  void write(String projectDir, ProjectManifest manifest) {
    final file = File(p.join(projectDir, fileName));

    final buffer = StringBuffer()
      ..writeln('# Managed by Geneser — edit with care.')
      ..writeln('geneser:')
      ..writeln('  version: ${manifest.geneserVersion}')
      ..writeln('  template:')
      ..writeln('    id: ${manifest.templateId}')
      ..writeln('  project:')
      ..writeln('    name: ${manifest.projectName}')
      ..writeln('    organization: ${manifest.organization}');

    if (manifest.features.isEmpty) {
      buffer.writeln('  features: []');
    } else {
      buffer.writeln('  features:');
      for (final feature in manifest.features) {
        buffer.writeln('    - $feature');
      }
    }

    file.writeAsStringSync(buffer.toString());
  }
}
