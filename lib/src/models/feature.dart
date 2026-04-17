class Feature {
  const Feature({
    required this.id,
    required this.name,
    required this.description,
    this.requiresIntegration,
    this.conflictsWith = const <String>[],
  });

  final String id;
  final String name;
  final String description;
  final String? requiresIntegration;
  final List<String> conflictsWith;
}
