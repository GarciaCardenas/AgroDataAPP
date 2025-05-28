import 'dart:convert';

class IdentificationResult {
  final CropResult crop;
  final DiseaseResult disease;

  IdentificationResult({required this.crop, required this.disease});

  factory IdentificationResult.fromJson(Map<String, dynamic> json) {
    return IdentificationResult(
      crop: CropResult.fromJson(json['result']['crop']),
      disease: DiseaseResult.fromJson(json['result']['disease']),
    );
  }
}

class CropResult {
  final List<Suggestion> suggestions;
  CropResult({required this.suggestions});
  factory CropResult.fromJson(Map<String, dynamic> json) {
    var list = (json['suggestions'] as List)
        .map((e) => Suggestion.fromJson(e))
        .toList();
    return CropResult(suggestions: list);
  }
}

class DiseaseResult {
  final List<Suggestion> suggestions;
  DiseaseResult({required this.suggestions});
  factory DiseaseResult.fromJson(Map<String, dynamic> json) {
    var list = (json['suggestions'] as List)
        .map((e) => Suggestion.fromJson(e))
        .toList();
    return DiseaseResult(suggestions: list);
  }
}

class Suggestion {
  final String id;
  final String name;
  final double probability;

  Suggestion({required this.id, required this.name, required this.probability});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'],
      name: json['name'],
      probability: (json['probability'] as num).toDouble(),
    );
  }
}