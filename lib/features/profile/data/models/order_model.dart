import 'package:perfume_app_mobile/features/perfume/data/models/perfume_model.dart';
import 'package:perfume_app_mobile/features/profile/domain/entities/order.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required int id,
    required int quantity,
    String? orderMessage,
    required DateTime createdAt,
    required PerfumeModel perfume, // This must be PerfumeModel if it's passed here
  }) : super(
    id: id,
    quantity: quantity,
    orderMessage: orderMessage,
    createdAt: createdAt,
    perfume: perfume, // Pass it directly to super
  );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Conditionally parse perfume. If 'perfume' key is not present or null,
    // we must provide a default/placeholder PerfumeModel because OrderEntity.perfume is non-nullable.
    final perfumeData = json['perfume'] as Map<String, dynamic>?;
    final PerfumeModel parsedPerfume;

    if (perfumeData != null) {
      // If perfume data exists in the JSON, parse it
      parsedPerfume = PerfumeModel.fromJson(perfumeData);
    } else {
      // If perfume data is not in the JSON (e.g., from a POST /order response),
      // provide a default/placeholder PerfumeModel. This is crucial because
      // OrderEntity.perfume is required and cannot be null.
      parsedPerfume = const  PerfumeModel( // Provide a default empty/placeholder PerfumeModel
        id: 0,
        name: '',
        brand: '',
        price: 0.0,
        stock: 0,
        description: '',
        size: 0,
        image: '',
        gender: '',
        season: '',
        occasion: '',
        intensity: '',
        fragranceFamily: '',
        topNotes: [],
        middleNotes: [],
        baseNotes: [],
        longevity: 0,
        sillage: 0,
        averageRating: 0.0,
        totalReviews: 0,
      );
    }

    return OrderModel(
      id: json['id'] as int,
      quantity: (json['quantity'] as num).toInt(),
      orderMessage: json['orderMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      perfume: parsedPerfume, // Use the parsed (or placeholder) perfume
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'orderMessage': orderMessage,
      'createdAt': createdAt.toIso8601String(),
      // Only include perfume if it's not the placeholder and can be cast
      'perfume': (perfume.id != -1 && perfume is PerfumeModel) ? (perfume as PerfumeModel).toJson() : null,
    };
  }
}
