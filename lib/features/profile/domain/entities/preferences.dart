import 'package:equatable/equatable.dart';

class PreferencesEntity extends Equatable {
  final String preferredGender;
  final List<String> favoriteSeasons;
  final List<String> preferredOccasions;
  final String intensityPreference;
  final List<String> fragranceFamilies;

  const PreferencesEntity({
    required this.preferredGender,
    required this.favoriteSeasons,
    required this.preferredOccasions,
    required this.intensityPreference,
    required this.fragranceFamilies,
  });

  @override
  List<Object> get props => [
    preferredGender,
    favoriteSeasons,
    preferredOccasions,
    intensityPreference,
    fragranceFamilies,
  ];
}