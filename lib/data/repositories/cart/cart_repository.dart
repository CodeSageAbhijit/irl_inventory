import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:irl_inventory/features/shop/models/cart_item_model.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';
import 'package:uuid/uuid.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user's cart (get the Cart document)
  Future<List<CartItem>> getCartItems(String userId) async {
    final doc = await _firestore.collection('carts').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      // Retrieve the items from cart (which now only contain item_id and quantity)
      return (data['items'] as List)
          .map((itemData) => CartItem.fromJson(itemData))
          .toList();
    } else {
      return []; // Return an empty list if no cart exists
    }
  }

  // Add item to the user's cart (update cart document)
  Future<void> addCartItem(String userId, CartItem cartItem) async {
    final cartRef = _firestore.collection('carts').doc(userId);

    // Fetch the current cart
    final cartSnapshot = await cartRef.get();
    if (cartSnapshot.exists) {
      final cartData = cartSnapshot.data();
      // If the cart exists, update it by adding a new item
      final updatedItems = List<Map<String, dynamic>>.from(cartData!['items']);
      updatedItems.add(cartItem.toJson());
      await cartRef.update({'items': updatedItems});
    } else {
      // If the cart doesn't exist, create a new one
      await cartRef.set({
        'user_id': userId,
        'items': [cartItem.toJson()],
      });
    }
  }

  // Fetch the full item details from the inventory using item_id
  Future<InventoryItem> getItemDetails(String itemId) async {
    final doc = await _firestore.collection('inventory_items').doc(itemId).get();
    if (doc.exists) {
      return InventoryItem.fromJson(doc.data()!);
    } else {
      throw Exception("Item not found");
    }
  }

//   // In your CartRepository
// Future<void> updateCartItem(String userId, CartItem cartItem) async {
//   final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);
  
//   await cartRef.update({
//     'items': FieldValue.arrayRemove([cartItem.toJson()]),
//   });
  
//   await cartRef.update({
//     'items': FieldValue.arrayUnion([cartItem.toJson()]),
//   });
// }

Future<void> updateCartItem(String userId, CartItem cartItem) async {
  final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);

  try {
    // Fetch the current cart
    final cartSnapshot = await cartRef.get();
    print('Fetched cart snapshot for userId: $userId');
    if (!cartSnapshot.exists) {
      print('Cart not found for user: $userId');
      throw Exception('Cart not found for user $userId');
    }

    final cartData = cartSnapshot.data();
    print('Cart data retrieved: $cartData');

    if (cartData == null || cartData['items'] == null) {
      print('No items found in cart data for user: $userId');
      throw Exception('No items in cart for user $userId');
    }

    final items = List<Map<String, dynamic>>.from(cartData['items']);
    print('Items in cart before update: $items');

    // Find the item and update its quantity
    final itemIndex = items.indexWhere((item) => item['item_id'] == cartItem.itemId);
    print('Index of item to update: $itemIndex');

    if (itemIndex != -1) {
      print('Updating item with itemId: ${cartItem.itemId}');
      items[itemIndex]['selectedQuantity'] = cartItem.selectedQuantity;
      print('Updated item: ${items[itemIndex]}');

      // Update the Firestore document
      await cartRef.update({'items': items});
      print('Cart updated successfully for user: $userId');
    } else {
      print('Cart item not found for itemId: ${cartItem.itemId}');
      throw Exception('Cart item not found for update');
    }
  } catch (e) {
    print('Error during updateCartItem: $e');
    rethrow; // Re-throw the exception to handle it further up the stack
  }
}


Future<void> storeRequestData({
    required String userId,
    required List<Map<String, dynamic>> resolvedCartItems,
    required String purpose,
    required int duration,
  }) async {
    try {
      // Generate unique request ID
      String requestId = const Uuid().v4();

      // Get the current timestamp
      String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Create the request payload
      Map<String, dynamic> requestData = {
        'user_id': userId,
        'cart_items': resolvedCartItems,
        'request_id': requestId,
        'timestamp': timestamp,
        'duration': duration,
        'purpose': purpose,
        'approval_status': 'Pending', // Default status
      };

      // Save to Firestore
      await _firestore.collection('requests').doc(requestId).set(requestData);
    } catch (e) {
      throw Exception('Failed to store request data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchResolvedCartItems(List<Map<String, dynamic>> cartItems) async {
  try {
    List<Map<String, dynamic>> resolvedCartItems = [];
    for (var cartItem in cartItems) {
      DocumentSnapshot<Map<String, dynamic>> inventoryDoc =
          await _firestore.collection('inventory_items').doc(cartItem['item_id']).get();

      if (inventoryDoc.exists) {
        Map<String, dynamic> itemData = inventoryDoc.data()!;
        itemData['selected_quantity'] = cartItem['selected_quantity']; // Add user-selected quantity
        resolvedCartItems.add(itemData);
      }
    }
    return resolvedCartItems;
  } catch (e) {
    throw Exception('Failed to fetch resolved cart items: $e');
  }
}


// In CartRepository:
Future<void> deleteCart(String userId) async {
  try {
    await _firestore.collection('carts').doc(userId).delete();
    print("Cart deleted for user: $userId");
  } catch (e) {
    throw Exception('Failed to delete cart: $e');
  }
}

// Function to fetch user requests based on userId
  Future<List<Map<String, dynamic>>> fetchUserRequests(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('requests')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> requests = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();

      return requests;
    } catch (e) {
      throw Exception('Failed to fetch user requests: $e');
    }
  }



}
