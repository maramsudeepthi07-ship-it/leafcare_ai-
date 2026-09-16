class Plant {
  final String id;
  final String scientificName;
  final Map<String, String> names;
  final Map<String, String> uses;
  final Map<String, String> preparation;
  final Map<String, String> duration;
  final Map<String, String> safety;

  const Plant({
    required this.id,
    required this.scientificName,
    required this.names,
    required this.uses,
    required this.preparation,
    required this.duration,
    required this.safety,
  });
}