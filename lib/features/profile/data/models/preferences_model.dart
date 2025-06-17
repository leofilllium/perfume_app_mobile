import '../../domain/entities/preferences.dart';

class PreferencesModel extends PreferencesEntity {
  const PreferencesModel({
    required String preferredGender,
    required List<String> favoriteSeasons,
    required List<String> preferredOccasions,
    required String intensityPreference,
    required List<String> fragranceFamilies,
  }) : super(
    preferredGender: preferredGender,
    favoriteSeasons: favoriteSeasons,
    preferredOccasions: preferredOccasions,
    intensityPreference: intensityPreference,
    fragranceFamilies: fragranceFamilies,
  );

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      preferredGender: json['preferredGender'] as String,
      favoriteSeasons: List<String>.from(json['favoriteSeasons'] as List),
      preferredOccasions: List<String>.from(json['preferredOccasions'] as List),
      intensityPreference: json['intensityPreference'] as String,
      fragranceFamilies: List<String>.from(json['fragranceFamilies'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredGender': preferredGender,
      'favoriteSeasons': favoriteSeasons,
      'preferredOccasions': preferredOccasions,
      'intensityPreference': intensityPreference,
      'fragranceFamilies': fragranceFamilies,
    };
  }
}