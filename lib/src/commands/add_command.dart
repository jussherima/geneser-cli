import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../models/feature.dart';
import '../models/registry.dart';
import '../services/feature_service.dart';
import '../services/project_manifest_service.dart';
import '../services/registry_service.dart';

class AddCommand extends Command<int> {
  AddCommand({
    required Logger logger,
    RegistryService? service,
    FeatureService? featureService,
    ProjectManifestService? manifestService,
  })  : _logger = logger,
        _service = service ?? RegistryService(),
        _featureService = featureService ?? FeatureService(logger: logger),
        _manifestService = manifestService ?? ProjectManifestService();

  @override
  String get name => 'add';

  @override
  String get description => 'Add a feature to an existing Geneser project.';

  final Logger _logger;
  final RegistryService _service;
  final FeatureService _featureService;
  final ProjectManifestService _manifestService;

  @override
  Future<int> run() async {
    final projectDir = Directory.current.path;
    final manifest = _manifestService.read(projectDir);

    if (manifest == null) {
      _logger
        ..err(
          'Not a Geneser project — no ${ProjectManifestService.fileName} '
          'found in $projectDir.',
        )
        ..info('Run this command from the root of a project created with '
            '"geneser create".');
      return ExitCode.usage.code;
    }

    _logger
      ..info('')
      ..info(styleBold.wrap('Add features to ${manifest.projectName}')!)
      ..info(darkGray.wrap('Template: ${manifest.templateId}')!)
      ..info('');

    final registryProgress = _logger.progress('Loading registry');
    final Registry registry;
    try {
      registry = await _service.load();
      registryProgress.complete('Registry loaded');
    } on Exception catch (e) {
      registryProgress.fail('Failed to load registry: $e');
      return ExitCode.unavailable.code;
    }

    final template = registry.templateById(manifest.templateId);
    if (template == null) {
      _logger.err(
        'Template "${manifest.templateId}" not found in the registry.',
      );
      return ExitCode.unavailable.code;
    }

    final compatibleFeatures = registry.features
        .where((f) => template.compatibleFeatures.contains(f.id))
        .where((f) => !manifest.features.contains(f.id))
        .toList();

    if (compatibleFeatures.isEmpty) {
      _logger
        ..info('')
        ..info('All compatible features are already installed.');
      return ExitCode.success.code;
    }

    final selectedFeatures = _logger.chooseAny<Feature>(
      'Features to add (space to toggle, enter to confirm):',
      choices: compatibleFeatures,
      display: (f) => f.name,
    );

    if (selectedFeatures.isEmpty) {
      _logger.warn('No features selected.');
      return ExitCode.success.code;
    }

    final conflicts = _detectConflicts(
      already: manifest.features,
      incoming: selectedFeatures,
    );
    if (conflicts.isNotEmpty) {
      _logger
        ..info('')
        ..err('Incompatible selection:');
      for (final conflict in conflicts) {
        _logger.err('  - $conflict');
      }
      return ExitCode.usage.code;
    }

    _logger.info('');
    for (final feature in selectedFeatures) {
      final brickPath = FeatureService.resolveFeatureBrickPath(feature.id);
      final result = await _featureService.apply(
        projectDir: projectDir,
        feature: feature,
        brickPath: brickPath,
      );
      if (!result.success) {
        _logger.err('Failed to apply "${feature.id}": ${result.error}');
        return ExitCode.software.code;
      }
    }

    _logger
      ..info('')
      ..success(
        '${selectedFeatures.length} feature'
        '${selectedFeatures.length == 1 ? '' : 's'} applied.',
      )
      ..info('')
      ..info(styleBold.wrap('Next steps')!)
      ..info(
        '  Open each feature\'s README.md in bricks/<id>/ for manual '
        'wiring (routes, etc.).',
      );

    return ExitCode.success.code;
  }

  List<String> _detectConflicts({
    required List<String> already,
    required List<Feature> incoming,
  }) {
    final conflicts = <String>[];
    final incomingIds = incoming.map((f) => f.id).toSet();
    final totalIds = <String>{...already, ...incomingIds};
    for (final feature in incoming) {
      for (final conflictId in feature.conflictsWith) {
        if (totalIds.contains(conflictId)) {
          conflicts.add('${feature.id} conflicts with $conflictId');
        }
      }
    }
    return conflicts;
  }
}
