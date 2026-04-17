class Template {
  const Template({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.compatibleFeatures,
  });

  final String id;
  final String name;
  final String description;
  final String author;
  final List<String> compatibleFeatures;
}
