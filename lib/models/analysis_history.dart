class AnalysisHistory {
  final String id;
  final String plantName;
  final String scientificName;
  final String disease;
  final double plantConfidence;
  final double diseaseConfidence;
  final double healthyProbability;
  final String healthStatus;
  final String severity;
  final DateTime dateTime;

  AnalysisHistory({
    required this.id,
    required this.plantName,
    required this.scientificName,
    required this.disease,
    required this.plantConfidence,
    required this.diseaseConfidence,
    required this.healthyProbability,
    required this.healthStatus,
    required this.severity,
    required this.dateTime,
  });
}