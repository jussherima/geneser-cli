/// Static validators used across commands.
class Validators {
  const Validators._();

  static final RegExp _packageNameRegex = RegExp(r'^[a-z][a-z0-9_]*$');

  static const Set<String> _reservedWords = <String>{
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'deferred',
    'do',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'function',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'of',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  /// Returns `null` if [value] is a valid Dart package name, otherwise an
  /// error message explaining why it is rejected.
  static String? packageName(String value) {
    if (value.isEmpty) {
      return 'Package name cannot be empty.';
    }
    if (!_packageNameRegex.hasMatch(value)) {
      return 'Package name must be snake_case: start with a lowercase letter '
          'and contain only lowercase letters, digits and underscores.';
    }
    if (_reservedWords.contains(value)) {
      return '"$value" is a reserved Dart keyword and cannot be used.';
    }
    return null;
  }

  static final RegExp _organizationRegex =
      RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');

  /// Validates a reverse-DNS organization identifier (e.g. `com.example`).
  static String? organization(String value) {
    if (value.isEmpty) {
      return 'Organization cannot be empty.';
    }
    if (!_organizationRegex.hasMatch(value)) {
      return 'Organization must be reverse-DNS notation (e.g. com.example).';
    }
    return null;
  }
}
