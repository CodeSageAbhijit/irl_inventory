class CartItem {
  final String itemId; // Only store the item_id reference
  int selectedQuantity; // Quantity of the item in the cart

  CartItem({
    required this.itemId,
    required this.selectedQuantity,
  });

  // Convert CartItem to JSON structure for Firestore
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'selectedQuantity': selectedQuantity,
    };
  }

  // Convert CartItem to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'selected_quantity': selectedQuantity,
    };
  }

  // Create CartItem from JSON data
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['item_id'] ?? '',
      selectedQuantity: json['selectedQuantity'] ?? 1,
    );
  }

   // Add the copyWith method
  CartItem copyWith({
    String? itemId,
    int? selectedQuantity,
  }) {
    return CartItem(
      itemId: itemId ?? this.itemId,
      selectedQuantity: selectedQuantity ?? this.selectedQuantity,
    );
  }
}
