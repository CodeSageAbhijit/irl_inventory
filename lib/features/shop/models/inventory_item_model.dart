import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  /// Fields for InventoryItem
  final int id;
  String name;
  String description;
  String imageUrl;
  String qrCode;
  int quantity;

  /// Constructor for InventoryItem
  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.qrCode,
    required this.quantity,
  });

  /// Static method to create an empty inventory item
  static InventoryItem empty() => InventoryItem(
        id: 0,
        name: '',
        description: '',
        imageUrl: '',
        qrCode: '',
        quantity: 0,
      );
      

      // Computed property to get the effective image URL
  String get effectiveImageUrl =>
      imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150?text=No+Image';

  /// Helper function to determine if the item is in stock
  bool get isInStock => quantity > 0;

  /// Convert model to JSON structure for storing in Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'qr_code': qrCode,
      'quantity': quantity,
    };
  }

  /// Factory method to create an InventoryItem from a Firestore document snapshot
  factory InventoryItem.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (doc.data() == null) return InventoryItem.empty();

    final data = doc.data()!;
    return InventoryItem(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      qrCode: data['qr_code'] ?? '',
      quantity: data['quantity'] ?? 0,
    );
  }

  /// Factory method to create an InventoryItem from JSON data
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      qrCode: json['qr_code'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  
}
