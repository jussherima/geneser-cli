import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../models/registry.dart';
import '../services/registry_service.dart';

class ListCommand extends Command<int> {
  ListCommand({required Logger logger, RegistryService? service})
      : _logger = logger,
        _service = service ?? RegistryService() {
    argParser.addFlag(
      'refresh',
      abbr: 'r',
      negatable: false,
      help: 'Bypass the cache and fetch the latest registry.',
    );
  }

  @override
  String get name => 'list';

  @override
  String get description => 'List available templates and features.';

  final Logger _logger;
  final RegistryService _service;

  @override
  Future<int> run() async {
    final refresh = (argResults?['refresh'] as bool?) ?? false;

    final progress = _logger.progress('Loading registry');
    final Registry registry;
    try {
      registry = await _service.load(forceRefresh: refresh);
      progress.complete('Registry loaded');
    } on Exception catch (e) {
      progress.fail('Failed to load registry: $e');
      return ExitCode.unavailable.code;
    }

    _logger
      ..info('')
      ..info(styleBold.wrap('Templates')!)
      ..info('');
    for (final template in registry.templates) {
      final author = darkGray.wrap('by ${template.author}')!;
      _logger
        ..info('  ${lightCyan.wrap(template.id)!}')
        ..info('    ${template.name}  $author')
        ..info('    ${darkGray.wrap(template.description)!}')
        ..info('');
    }

    _logger
      ..info(styleBold.wrap('Features')!)
      ..info('');
    for (final feature in registry.features) {
      _logger
        ..info('  ${lightGreen.wrap(feature.id)!}')
        ..info('    ${feature.name}')
        ..info('    ${darkGray.wrap(feature.description)!}')
        ..info('');
    }

    _logger.info(
      darkGray.wrap(
        'Use "geneser create" to start a new project from any template.',
      )!,
    );

    return ExitCode.success.code;
  }
}
