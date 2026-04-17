import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import 'src/commands/commands.dart';
import 'src/version.dart';

/// Top-level runner for the Geneser CLI.
class GeneserRunner extends CommandRunner<int> {
  GeneserRunner({Logger? logger})
      : _logger = logger ?? Logger(),
        super(
          'geneser',
          'Skip the Flutter boilerplate. Compose your stack, ship faster.',
        ) {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the current version.',
    );

    addCommand(CreateCommand(logger: _logger));
    addCommand(AddCommand(logger: _logger));
    addCommand(ListCommand(logger: _logger));
    addCommand(DoctorCommand(logger: _logger));
  }

  final Logger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      if (topLevelResults['version'] == true) {
        _logger.info(packageVersion);
        return ExitCode.success.code;
      }
      return await runCommand(topLevelResults) ?? ExitCode.success.code;
    } on FormatException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    }
  }
}
