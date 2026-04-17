import 'package:geneser/geneser.dart';
import 'package:test/test.dart';

void main() {
  group('GeneserRunner', () {
    test('can be instantiated', () {
      expect(GeneserRunner(), isA<GeneserRunner>());
    });

    test('exposes expected commands', () {
      final runner = GeneserRunner();
      expect(
        runner.commands.keys,
        containsAll(<String>['create', 'add', 'list', 'doctor']),
      );
    });
  });
}
