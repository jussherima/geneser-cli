import 'package:geneser/src/utils/validators.dart';
import 'package:test/test.dart';

void main() {
  group('Validators.packageName', () {
    test('accepts valid snake_case names', () {
      expect(Validators.packageName('my_app'), isNull);
      expect(Validators.packageName('todo'), isNull);
      expect(Validators.packageName('my_app_v2'), isNull);
      expect(Validators.packageName('a'), isNull);
    });

    test('rejects empty values', () {
      expect(Validators.packageName(''), contains('empty'));
    });

    test('rejects uppercase letters', () {
      expect(Validators.packageName('MyApp'), isNotNull);
      expect(Validators.packageName('my_App'), isNotNull);
    });

    test('rejects names starting with a digit', () {
      expect(Validators.packageName('1app'), isNotNull);
    });

    test('rejects dashes and dots', () {
      expect(Validators.packageName('my-app'), isNotNull);
      expect(Validators.packageName('my.app'), isNotNull);
    });

    test('rejects reserved Dart keywords', () {
      expect(Validators.packageName('class'), contains('reserved'));
      expect(Validators.packageName('return'), contains('reserved'));
      expect(Validators.packageName('abstract'), contains('reserved'));
    });
  });

  group('Validators.organization', () {
    test('accepts reverse-DNS identifiers', () {
      expect(Validators.organization('com.example'), isNull);
      expect(Validators.organization('io.github.my_user'), isNull);
      expect(Validators.organization('dev.my_company.app1'), isNull);
    });

    test('rejects single segments', () {
      expect(Validators.organization('com'), isNotNull);
      expect(Validators.organization('example'), isNotNull);
    });

    test('rejects uppercase and illegal characters', () {
      expect(Validators.organization('Com.Example'), isNotNull);
      expect(Validators.organization('com-example.app'), isNotNull);
    });

    test('rejects empty values', () {
      expect(Validators.organization(''), contains('empty'));
    });
  });
}
