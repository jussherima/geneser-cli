import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

import '../services/project_manifest_service.dart';

class DoctorCommand extends Command<int> {
  DoctorCommand({
    required Logger logger,
    ProjectManifestService? manifestService,
  })  : _logger = logger,
        _manifestService = manifestService ?? ProjectManifestService();

  @override
  String get name => 'doctor';

  @override
  String get description =>
      'Diagnose your local environment and current project.';

  final Logger _logger;
  final ProjectManifestService _manifestService;

  @override
  Future<int> run() async {
    _logger
      ..info('')
      ..info(styleBold.wrap('Environment checks')!)
      ..info('');

    final checks = <_Check>[
      _Check('Dart SDK', 'dart', <String>['--version']),
      _Check('Flutter SDK', 'flutter', <String>['--version']),
      _Check('Git', 'git', <String>['--version']),
    ];

    var failures = 0;
    for (final check in checks) {
      final progress = _logger.progress(check.name);
      final result = await _runCheck(check);
      if (result.ok) {
        progress.complete('${check.name.padRight(14)} ${result.message}');
      } else {
        failures++;
        progress.fail('${check.name.padRight(14)} ${result.message}');
      }
    }

    _logger.info('');
    _reportProjectContext();

    if (failures == 0) {
      _logger.success('All checks passed.');
      return ExitCode.success.code;
    }
    _logger.err(
      '$failures check${failures == 1 ? '' : 's'} failed. '
      'Install the missing tool(s) and try again.',
    );
    return ExitCode.unavailable.code;
  }

  void _reportProjectContext() {
    final manifest = _manifestService.read(Directory.current.path);
    if (manifest == null) {
      _logger
        ..info(
          darkGray.wrap(
            'Not inside a Geneser project (no .geneser.yaml here).',
          )!,
        )
        ..info('');
      return;
    }

    final featureList = manifest.features.isEmpty
        ? darkGray.wrap('(none)')!
        : manifest.features.join(', ');

    _logger
      ..info(styleBold.wrap('Current project')!)
      ..info('  Name:      ${manifest.projectName}')
      ..info('  Template:  ${manifest.templateId}')
      ..info('  Features:  $featureList')
      ..info('  Created by Geneser ${manifest.geneserVersion}')
      ..info('');
  }

  Future<_CheckResult> _runCheck(_Check check) async {
    try {
      final result = await Process.run(check.executable, check.args);
      if (result.exitCode != 0) {
        return _CheckResult.failure(
          'command exited with code ${result.exitCode}',
        );
      }
      final output = (result.stdout as String).trim();
      final firstLine = output.isEmpty ? 'installed' : output.split('\n').first;
      return _CheckResult.success(firstLine);
    } on ProcessException {
      return _CheckResult.failure('not found in PATH');
    }
  }
}

class _Check {
  const _Check(this.name, this.executable, this.args);
  final String name;
  final String executable;
  final List<String> args;
}

class _CheckResult {
  const _CheckResult._({required this.ok, required this.message});
  const _CheckResult.success(String message)
      : this._(ok: true, message: message);
  const _CheckResult.failure(String message)
      : this._(ok: false, message: message);

  final bool ok;
  final String message;
}
