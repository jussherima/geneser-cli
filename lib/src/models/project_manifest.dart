/// Snapshot of a generated project's Geneser state.
///
/// Serialized to `.geneser.yaml` at the root of every generated project so
/// that `geneser add` can reason about what's already installed.
class ProjectManifest {
  const ProjectManifest({
    required this.geneserVersion,
    required this.templateId,
    required this.projectName,
    required this.organization,
    required this.features,
  });

  final String geneserVersion;
  final String templateId;
  final String projectName;
  final String organization;
  final List<String> features;

  ProjectManifest copyWith({
    String? geneserVersion,
    String? templateId,
    String? projectName,
    String? organization,
    List<String>? features,
  }) {
    return ProjectManifest(
      geneserVersion: geneserVersion ?? this.geneserVersion,
      templateId: templateId ?? this.templateId,
      projectName: projectName ?? this.projectName,
      organization: organization ?? this.organization,
      features: features ?? this.features,
    );
  }
}
