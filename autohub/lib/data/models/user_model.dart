import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String? profilePhotoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CarModel> cars;
  final int totalWins;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.profilePhotoUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.cars = const [],
    this.totalWins = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'],
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      cars: (data['cars'] as List<dynamic>? ?? [])
          .map((car) => CarModel.fromMap(car))
          .toList(),
      totalWins: data['totalWins'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'cars': cars.map((car) => car.toMap()).toList(),
      'totalWins': totalWins,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? profilePhotoUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CarModel>? cars,
    int? totalWins,
    int? followersCount,
    int? followingCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cars: cars ?? this.cars,
      totalWins: totalWins ?? this.totalWins,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      bio: map['bio'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      cars: (map['cars'] as List<dynamic>? ?? [])
          .map((car) => CarModel.fromMap(car))
          .toList(),
      totalWins: map['totalWins'] ?? 0,
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'cars': cars.map((car) => car.toMap()).toList(),
      'totalWins': totalWins,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }
}

class CarModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? color;
  final List<String> imageUrls;
  final List<String> modifications;
  final String? description;
  final DateTime createdAt;

  CarModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.color,
    this.imageUrls = const [],
    this.modifications = const [],
    this.description,
    required this.createdAt,
  });

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? 0,
      color: map['color'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      modifications: List<String>.from(map['modifications'] ?? []),
      description: map['description'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'imageUrls': imageUrls,
      'modifications': modifications,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get displayName => '$year $make $model';

  CarModel copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? color,
    List<String>? imageUrls,
    List<String>? modifications,
    String? description,
    DateTime? createdAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      imageUrls: imageUrls ?? this.imageUrls,
      modifications: modifications ?? this.modifications,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
