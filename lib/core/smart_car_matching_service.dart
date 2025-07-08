import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

const String smartCarMatchingBaseUrl = 'https://4cf8-2c0f-fc89-f6-747d-b8a8-42d1-79a-4404.ngrok-free.app/api/'; // ← غيّره حسب رابطك

class SmartCarMatchingService {
  static final SmartCarMatchingService _instance = SmartCarMatchingService._internal();
  factory SmartCarMatchingService() => _instance;
  SmartCarMatchingService._internal();

  final ApiService _apiService = ApiService();

  /// Get car cluster for uploaded image
  Future<CarCluster> getCarCluster(File imageFile) async {
    try {
      // Create form data for file upload
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // Use Dio with ML service base URL
      final dio = Dio(
        BaseOptions(
          baseUrl: smartCarMatchingBaseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final response = await dio.post('classify-car/', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        return CarCluster.fromJson(data);
      } else {
        throw Exception('Failed to get car cluster: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getCarCluster: $e');
      rethrow;
    }
  }

  /// Get cars by cluster name
  Future<List<CarDetails>> getCarsByCluster(String clusterName) async {
    try {
      final response = await _apiService.get('cars/cluster/$clusterName/');

      if (response.statusCode == 200) {
        List<CarDetails> cars = [];
        for (var carData in response.data['cars'] ?? []) {
          cars.add(CarDetails.fromJson(carData));
        }
        return cars;
      } else {
        print('Failed to get cars by cluster: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting cars by cluster: $e');
      return [];
    }
  }

  /// Get detailed car information for a car
  Future<CarDetails?> getCarDetails(String carId) async {
    try {
      final response = await _apiService.get('cars/$carId/');

      if (response.statusCode == 200) {
        return CarDetails.fromJson(response.data);
      } else {
        print('Failed to get car details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting car details: $e');
      return null;
    }
  }
}

/// Model class for car cluster results
class CarCluster {
  final String clusterName;
  final double confidence;
  final String? description;
  final List<CarDetails>? carsInCluster;

  CarCluster({
    required this.clusterName,
    required this.confidence,
    this.description,
    this.carsInCluster,
  });

  factory CarCluster.fromJson(Map<String, dynamic> json) {
    return CarCluster(
      clusterName: json['matched_class'] ?? json['cluster_name'] ?? '', // ← دعم مفتاح الباك الحالي
      confidence: (json['confidence'] ?? 0.0).toDouble(), // ← دعم للثقة لو موجودة
      description: json['description'],
      carsInCluster: json['cars'] != null
          ? List<CarDetails>.from(json['cars'].map((x) => CarDetails.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cluster_name': clusterName,
      'confidence': confidence,
      'description': description,
      'cars': carsInCluster?.map((car) => car.toJson()).toList(),
    };
  }

  double get confidencePercentage => (confidence * 100);
  String get confidenceText => '${confidencePercentage.toStringAsFixed(1)}%';
  bool get isHighConfidence => confidence > 0.7;
  bool get isVeryHighConfidence => confidence > 0.9;
}

/// CarDetails Model
class CarDetails {
  final int id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final String transmissionType;
  final String fuelType;
  final int seatingCapacity;
  final double avgRating;
  final int totalReviews;
  final String ownerName;
  final double ownerRating;
  final List<CarImage> images;

  CarDetails({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    required this.transmissionType,
    required this.fuelType,
    required this.seatingCapacity,
    required this.avgRating,
    required this.totalReviews,
    required this.ownerName,
    required this.ownerRating,
    required this.images,
  });

  factory CarDetails.fromJson(Map<String, dynamic> json) {
    return CarDetails(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      plateNumber: json['plate_number'],
      transmissionType: json['transmission_type'],
      fuelType: json['fuel_type'],
      seatingCapacity: json['seating_capacity'],
      avgRating: json['avg_rating']?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      ownerName: json['owner_name'],
      ownerRating: json['owner_rating']?.toDouble() ?? 0.0,
      images: json['images'] != null
          ? List<CarImage>.from(json['images'].map((x) => CarImage.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'plate_number': plateNumber,
      'transmission_type': transmissionType,
      'fuel_type': fuelType,
      'seating_capacity': seatingCapacity,
      'avg_rating': avgRating,
      'total_reviews': totalReviews,
      'owner_name': ownerName,
      'owner_rating': ownerRating,
      'images': images.map((image) => image.toJson()).toList(),
    };
  }

  String? get firstImageUrl {
    if (images.isNotEmpty) {
      return images.first.url;
    }
    return null;
  }
}

class CarImage {
  final int id;
  final String url;
  final String type;

  CarImage({
    required this.id,
    required this.url,
    required this.type,
  });

  factory CarImage.fromJson(Map<String, dynamic> json) {
    return CarImage(
      id: json['id'],
      url: json['url'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
    };
  }
}
