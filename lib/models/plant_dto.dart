class PlantDTO {
  int? id;
  String? firebaseId;
  String? name;
  double? price;
  String? category;
  String? description;
  String? careInstructions;
  String? imageUrl;
  String? image; // Para compatibilidad con Firebase
  double? rating;
  int? reviews;
  String? createdAt;
  String? updatedAt;
  int? needsSync;
  int? isDeleted;

  PlantDTO({
    this.id,
    this.firebaseId,
    this.name,
    this.price,
    this.category,
    this.description,
    this.careInstructions,
    this.imageUrl,
    this.image,
    this.rating,
    this.reviews,
    this.createdAt,
    this.updatedAt,
    this.needsSync,
    this.isDeleted,
  });

  factory PlantDTO.fromJson(Map<String, dynamic> json) {
    return PlantDTO(
      id: json['id'],
      firebaseId: json['firebase_id'],
      name: json['name'],
      price: json['price']?.toDouble(),
      category: json['category'],
      description: json['description'],
      careInstructions: json['care_instructions'],
      imageUrl: json['image_url'],
      image: json['image'], // Para compatibilidad
      rating: json['rating']?.toDouble(),
      reviews: json['reviews'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      needsSync: json['needs_sync'],
      isDeleted: json['is_deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_id': firebaseId,
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'care_instructions': careInstructions,
      'image_url': imageUrl,
      'image': image ?? imageUrl, // Usar image o imageUrl
      'rating': rating,
      'reviews': reviews,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'needs_sync': needsSync,
      'is_deleted': isDeleted,
    };
  }

  @override
  String toString() {
    return 'PlantDTO{id: $id, name: $name, price: $price, category: $category}';
  }
}