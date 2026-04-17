import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../models/feature.dart';
import '../models/registry.dart';
import '../models/template.dart';

/// Loads the Geneser registry from a remote URL with local caching.
///
/// Resolution order:
///   1. Remote fetch when the cache is stale or [forceRefresh] is true.
///   2. Local cache when the remote is unreachable.
///   3. Built-in registry as a last-resort fallback.
class RegistryService {
  RegistryService({
    http.Client? client,
    String? cacheDir,
    String? registryUrl,
    Duration cacheTtl = const Duration(hours: 1),
  })  : _client = client ?? http.Client(),
        _cacheDir = cacheDir ?? _defaultCacheDir(),
        _registryUrl = registryUrl ?? _defaultRegistryUrl,
        _cacheTtl = cacheTtl;

  static const String _defaultRegistryUrl =
      'https://raw.githubusercontent.com/jussherima/geneser-bricks/main/registry.yaml';

  final http.Client _client;
  final String _cacheDir;
  final String _registryUrl;
  final Duration _cacheTtl;

  static String _defaultCacheDir() {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.systemTemp.path;
    return p.join(home, '.geneser', 'cache');
  }

  String get _cachePath => p.join(_cacheDir, 'registry.yaml');

  /// Load the registry, using the cache when appropriate.
  Future<Registry> load({bool forceRefresh = false}) async {
    if (!forceRefresh && _cacheIsFresh()) {
      final cached = _readCache();
      if (cached != null) return cached;
    }

    try {
      final response = await _client
          .get(Uri.parse(_registryUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        await _writeCache(response.body);
        return parseYaml(response.body);
      }
    } on Exception {
      // Network or parsing failure — fall through to cache or builtin.
    }

    return _readCache() ?? Registry.builtin;
  }

  bool _cacheIsFresh() {
    final file = File(_cachePath);
    if (!file.existsSync()) return false;
    final age = DateTime.now().difference(file.lastModifiedSync());
    return age < _cacheTtl;
  }

  Registry? _readCache() {
    final file = File(_cachePath);
    if (!file.existsSync()) return null;
    try {
      return parseYaml(file.readAsStringSync());
    } on Exception {
      return null;
    }
  }

  Future<void> _writeCache(String content) async {
    final dir = Directory(_cacheDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    await File(_cachePath).writeAsString(content);
  }

  /// Parse a registry document from its YAML source.
  ///
  /// Exposed as a static method so tests can exercise it directly.
  static Registry parseYaml(String source) {
    final Object? doc = loadYaml(source);
    if (doc is! YamlMap) {
      throw const FormatException('Registry root must be a YAML map.');
    }

    final templates = <Template>[];
    final templatesYaml = doc['templates'];
    if (templatesYaml is YamlList) {
      for (final entry in templatesYaml) {
        if (entry is! YamlMap) continue;
        templates.add(_parseTemplate(entry));
      }
    }

    final features = <Feature>[];
    final featuresYaml = doc['features'];
    if (featuresYaml is YamlList) {
      for (final entry in featuresYaml) {
        if (entry is! YamlMap) continue;
        features.add(_parseFeature(entry));
      }
    }

    return Registry(templates: templates, features: features);
  }

  static Template _parseTemplate(YamlMap map) {
    return Template(
      id: _requireString(map, 'id'),
      name: _requireString(map, 'name'),
      description: _requireString(map, 'description'),
      author: _requireString(map, 'author'),
      compatibleFeatures: _optionalStringList(map, 'compatible_features'),
    );
  }

  static Feature _parseFeature(YamlMap map) {
    return Feature(
      id: _requireString(map, 'id'),
      name: _requireString(map, 'name'),
      description: _requireString(map, 'description'),
      requiresIntegration: map['requires_integration'] as String?,
      conflictsWith: _optionalStringList(map, 'conflicts_with'),
    );
  }

  static String _requireString(YamlMap map, String key) {
    final value = map[key];
    if (value is! String) {
      throw FormatException('Missing required String field "$key".');
    }
    return value;
  }

  static List<String> _optionalStringList(YamlMap map, String key) {
    final value = map[key];
    if (value is YamlList) {
      return value.cast<String>().toList();
    }
    return const <String>[];
  }
}
