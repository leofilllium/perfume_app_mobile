import '../../domain/entities/perfume.dart';

class PerfumeModel extends Perfume {
  const PerfumeModel({
    required int id,
    required String name,
    required String brand,
    required double price,
    required int stock,
    required String description,
    required int size,
    String? image,
    required String gender,
    required String season,
    required String occasion,
    required String intensity,
    required String fragranceFamily,
    required List<String> topNotes,
    required List<String> middleNotes,
    required List<String> baseNotes,
    required int longevity,
    required int sillage,
    required double averageRating,
    required int totalReviews,
  }) : super(
    id: id,
    name: name,
    brand: brand,
    price: price,
    stock: stock,
    description: description,
    size: size,
    image: image,
    gender: gender,
    season: season,
    occasion: occasion,
    intensity: intensity,
    fragranceFamily: fragranceFamily,
    topNotes: topNotes,
    middleNotes: middleNotes,
    baseNotes: baseNotes,
    longevity: longevity,
    sillage: sillage,
    averageRating: averageRating,
    totalReviews: totalReviews,
  );

  factory PerfumeModel.fromJson(Map<String, dynamic> json) {
    return PerfumeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      description: json['description'] as String,
      size: (json['size'] as num).toInt(),
      image: json['image'] as String?,
      gender: json['gender'] as String,
      season: json['season'] as String,
      occasion: json['occasion'] as String,
      intensity: json['intensity'] as String,
      fragranceFamily: json['fragranceFamily'] as String,
      topNotes: List<String>.from(json['topNotes'] as List),
      middleNotes: List<String>.from(json['middleNotes'] as List),
      baseNotes: List<String>.from(json['baseNotes'] as List),
      longevity: (json['longevity'] as num).toInt(),
      sillage: (json['sillage'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'stock': stock,
      'description': description,
      'size': size,
      'image': image,
      'gender': gender,
      'season': season,
      'occasion': occasion,
      'intensity': intensity,
      'fragranceFamily': fragranceFamily,
      'topNotes': topNotes,
      'middleNotes': middleNotes,
      'baseNotes': baseNotes,
      'longevity': longevity,
      'sillage': sillage,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}