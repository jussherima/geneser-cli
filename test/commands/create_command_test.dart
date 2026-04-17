import 'package:geneser/geneser.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';

/// Tests intentionally provide all prompt-able flags so the command never
/// blocks on stdin in a non-interactive test environment.
void main() {
  group('CreateCommand non-interactive validation', () {
    late GeneserRunner runner;

    setUp(() {
      runner = GeneserRunner(logger: Logger());
    });

    test('rejects an invalid --name (snake_case violation)', () async {
      final code = await runner.run(<String>[
        'create',
        '--name',
        'InvalidCamel',
        '--organization',
        'com.example',
        '--template',
        'starter_riverpod_gorouter',
        '--yes',
      ]);
      expect(code, ExitCode.usage.code);
    });

    test('rejects an unknown --template', () async {
      final code = await runner.run(<String>[
        'create',
        '--name',
        'valid_name',
        '--organization',
        'com.example',
        '--template',
        'does_not_exist',
        '--yes',
      ]);
      expect(code, ExitCode.usage.code);
    });

    test('rejects an unknown --feature', () async {
      final code = await runner.run(<String>[
        'create',
        '--name',
        'valid_name',
        '--organization',
        'com.example',
        '--template',
        'starter_riverpod_gorouter',
        '--feature',
        'does_not_exist',
        '--yes',
      ]);
      expect(code, ExitCode.usage.code);
    });

    test('rejects an invalid --organization', () async {
      final code = await runner.run(<String>[
        'create',
        '--name',
        'valid_name',
        '--organization',
        'NotReverseDNS',
        '--template',
        'starter_riverpod_gorouter',
        '--yes',
      ]);
      expect(code, ExitCode.usage.code);
    });
  });
}
