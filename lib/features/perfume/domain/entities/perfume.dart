import 'package:equatable/equatable.dart';

class Perfume extends Equatable {
  final int id; // Changed to int based on API
  final String name;
  final String brand;
  final double price;
  final int stock; // New field
  final String description; // New field
  final int size;
  final String? image;
  final String gender;
  final String season; // New field
  final String occasion; // New field
  final String intensity; // New field
  final String fragranceFamily; // New field
  final List<String> topNotes; // New field
  final List<String> middleNotes; // New field
  final List<String> baseNotes; // New field
  final int longevity; // New field
  final int sillage; // New field
  final double averageRating; // New field
  final int totalReviews; // New field

  const Perfume({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.stock,
    required this.description,
    required this.size,
    this.image,
    required this.gender,
    required this.season,
    required this.occasion,
    required this.intensity,
    required this.fragranceFamily,
    required this.topNotes,
    required this.middleNotes,
    required this.baseNotes,
    required this.longevity,
    required this.sillage,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    brand,
    price,
    stock,
    description,
    size,
    image,
    gender,
    season,
    occasion,
    intensity,
    fragranceFamily,
    topNotes,
    middleNotes,
    baseNotes,
    longevity,
    sillage,
    averageRating,
    totalReviews,
  ];
}