import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;

import '../models/feature.dart';
import '../models/registry.dart';
import '../models/template.dart';
import '../services/feature_service.dart';
import '../services/generator_service.dart';
import '../services/registry_service.dart';
import '../utils/validators.dart';

class CreateCommand extends Command<int> {
  CreateCommand({
    required Logger logger,
    RegistryService? service,
    GeneratorService? generator,
    FeatureService? featureService,
  })  : _logger = logger,
        _service = service ?? RegistryService(),
        _generator = generator ?? GeneratorService(logger: logger),
        _featureService = featureService ?? FeatureService(logger: logger) {
    argParser
      ..addFlag(
        'refresh',
        negatable: false,
        help: 'Bypass the cache and fetch the latest registry.',
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        negatable: false,
        help: 'Skip the confirmation prompt (useful with flags below).',
      )
      ..addOption(
        'name',
        help: 'Project name in snake_case. Skips the interactive prompt.',
      )
      ..addOption(
        'template',
        abbr: 't',
        help: 'Template id to use. Skips the architecture picker.',
      )
      ..addOption(
        'organization',
        abbr: 'o',
        help: 'Organization in reverse-DNS notation (default: com.example).',
      )
      ..addMultiOption(
        'feature',
        abbr: 'f',
        help: 'Feature id to include (repeatable).',
      );
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Create a new Flutter project from a template.';

  final Logger _logger;
  final RegistryService _service;
  final GeneratorService _generator;
  final FeatureService _featureService;

  @override
  Future<int> run() async {
    final refresh = (argResults?['refresh'] as bool?) ?? false;
    final skipConfirmation = (argResults?['yes'] as bool?) ?? false;

    final registryProgress = _logger.progress('Loading registry');
    final Registry registry;
    try {
      registry = await _service.load(forceRefresh: refresh);
      registryProgress.complete('Registry loaded');
    } on Exception catch (e) {
      registryProgress.fail('Failed to load registry: $e');
      return ExitCode.unavailable.code;
    }

    if (registry.templates.isEmpty) {
      _logger.err('No templates available in the registry.');
      return ExitCode.unavailable.code;
    }

    final String projectName;
    final String organization;
    final Template selectedTemplate;
    final List<Feature> selectedFeatures;

    try {
      projectName = _resolveProjectName();
      organization = _resolveOrganization();
      selectedTemplate = _resolveTemplate(registry);
      selectedFeatures = _resolveFeatures(registry, selectedTemplate);
    } on UsageException catch (e) {
      _logger.err(e.message);
      return ExitCode.usage.code;
    }

    final conflicts = _detectConflicts(selectedFeatures);
    if (conflicts.isNotEmpty) {
      _logger
        ..info('')
        ..err('Incompatible selection:');
      for (final conflict in conflicts) {
        _logger.err('  - $conflict');
      }
      return ExitCode.usage.code;
    }

    _printSummary(
      projectName: projectName,
      organization: organization,
      template: selectedTemplate,
      features: selectedFeatures,
    );

    if (!skipConfirmation) {
      final confirmed = _logger.confirm(
        'Generate this project?',
        defaultValue: true,
      );
      if (!confirmed) {
        _logger
          ..info('')
          ..warn('Cancelled.');
        return ExitCode.success.code;
      }
    }

    final targetPath = p.absolute(projectName);
    final brickPath = GeneratorService.resolveBrickPath(selectedTemplate.id);

    _logger.info('');
    final result = await _generator.generate(
      GenerationRequest(
        projectName: projectName,
        organization: organization,
        description: 'A new Flutter project generated with Geneser.',
        templateId: selectedTemplate.id,
        brickPath: brickPath,
        targetDir: targetPath,
        features: selectedFeatures.map((f) => f.id).toList(),
      ),
    );

    if (!result.success) {
      _logger
        ..info('')
        ..err('Generation failed: ${result.error ?? 'unknown error'}');
      return ExitCode.software.code;
    }

    for (final feature in selectedFeatures) {
      final featureBrickPath =
          FeatureService.resolveFeatureBrickPath(feature.id);
      final featureResult = await _featureService.apply(
        projectDir: targetPath,
        feature: feature,
        brickPath: featureBrickPath,
      );
      if (!featureResult.success) {
        _logger.warn(
          'Failed to apply "${feature.id}": ${featureResult.error}. '
          'You can retry with "geneser add" inside the project.',
        );
      }
    }

    _logger
      ..info('')
      ..success('Project created at ${result.outputPath}')
      ..info('')
      ..info(styleBold.wrap('Next steps')!)
      ..info('  cd $projectName')
      ..info('  flutter run');

    return ExitCode.success.code;
  }

  String _resolveProjectName() {
    final argValue = argResults?['name'] as String?;
    if (argValue != null) {
      final error = Validators.packageName(argValue);
      if (error != null) {
        throw UsageException('Invalid --name: $error', argParser.usage);
      }
      return argValue;
    }
    _logger
      ..info('')
      ..info(styleBold.wrap('Create a new Flutter project')!)
      ..info('');
    return _promptValidated(
      'Project name (snake_case):',
      Validators.packageName,
    );
  }

  String _resolveOrganization() {
    final argValue = argResults?['organization'] as String?;
    if (argValue != null) {
      final error = Validators.organization(argValue);
      if (error != null) {
        throw UsageException(
          'Invalid --organization: $error',
          argParser.usage,
        );
      }
      return argValue;
    }
    return _promptValidated(
      'Organization (reverse-DNS, e.g. com.example):',
      Validators.organization,
      defaultValue: 'com.example',
    );
  }

  Template _resolveTemplate(Registry registry) {
    final argValue = argResults?['template'] as String?;
    if (argValue != null) {
      final template = registry.templateById(argValue);
      if (template == null) {
        final available = registry.templates.map((t) => t.id).join(', ');
        throw UsageException(
          'Template "$argValue" not found. Available: $available',
          argParser.usage,
        );
      }
      return template;
    }
    _logger.info('');
    return _logger.chooseOne<Template>(
      'Choose an architecture:',
      choices: registry.templates,
      display: (t) => '${t.name}  ${darkGray.wrap('by ${t.author}')!}',
    );
  }

  List<Feature> _resolveFeatures(Registry registry, Template template) {
    final argValues = (argResults?['feature'] as List<String>?) ?? <String>[];
    if (argValues.isNotEmpty) {
      final features = <Feature>[];
      for (final id in argValues) {
        final feature = registry.featureById(id);
        if (feature == null) {
          throw UsageException(
            'Feature "$id" not found in the registry.',
            argParser.usage,
          );
        }
        if (!template.compatibleFeatures.contains(id)) {
          throw UsageException(
            'Feature "$id" is not compatible with template '
            '"${template.id}".',
            argParser.usage,
          );
        }
        features.add(feature);
      }
      return features;
    }

    // If template came from arg but no features flag, don't prompt
    // (user is likely scripting and wanted zero features).
    final templateFromArg = argResults?['template'] != null;
    if (templateFromArg) return <Feature>[];

    final compatibleFeatures = registry.features
        .where((f) => template.compatibleFeatures.contains(f.id))
        .toList();
    if (compatibleFeatures.isEmpty) return <Feature>[];

    return _logger.chooseAny<Feature>(
      'Features to include (space to toggle, enter to confirm):',
      choices: compatibleFeatures,
      display: (f) => f.name,
    );
  }

  String _promptValidated(
    String message,
    String? Function(String) validator, {
    String? defaultValue,
  }) {
    while (true) {
      final value = _logger.prompt(message, defaultValue: defaultValue);
      final error = validator(value);
      if (error == null) return value;
      _logger.err(error);
    }
  }

  List<String> _detectConflicts(List<Feature> selected) {
    final conflicts = <String>[];
    final selectedIds = selected.map((f) => f.id).toSet();
    for (final feature in selected) {
      for (final conflictId in feature.conflictsWith) {
        if (selectedIds.contains(conflictId)) {
          conflicts.add('${feature.id} conflicts with $conflictId');
        }
      }
    }
    return conflicts;
  }

  void _printSummary({
    required String projectName,
    required String organization,
    required Template template,
    required List<Feature> features,
  }) {
    final featureNames = features.isEmpty
        ? darkGray.wrap('(none)')!
        : features.map((f) => f.name).join(', ');

    _logger
      ..info('')
      ..info(styleBold.wrap('Summary')!)
      ..info('  Project:       $projectName')
      ..info('  Organization:  $organization')
      ..info('  Template:      ${template.name}')
      ..info('  Features:      $featureNames')
      ..info('');
  }
}
