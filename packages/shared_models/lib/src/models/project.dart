class Project {
  const Project({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? code;
  final String? description;
  final bool isActive;
}
