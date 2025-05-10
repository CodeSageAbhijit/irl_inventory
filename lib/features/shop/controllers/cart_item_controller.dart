import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/data/repositories/cart/cart_repository.dart';
import 'package:irl_inventory/features/shop/models/cart_item_model.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();
  final CartRepository cartRepository = Get.put(CartRepository());

  RxList<CartItem> cartItems = <CartItem>[].obs;
  RxList<InventoryItem> resolvedInventoryItems = <InventoryItem>[].obs;
  RxBool isLoading = true.obs;
  RxBool isProcessing = false.obs; // For add/remove operations

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty cart and loading false
    isLoading.value = false;
    cartItems.clear();
    resolvedInventoryItems.clear();
  }


  // In CartController
Future<void> addCartItem(String userId, CartItem cartItem) async {
  try {
    isProcessing.value = true;
    
    // Check if item already exists in cart
    final existingItemIndex = cartItems.indexWhere(
      (item) => item.itemId == cartItem.itemId
    );
    
    if (existingItemIndex >= 0) {
      // Item exists - update quantity instead of adding new
      final existingItem = cartItems[existingItemIndex];
      final updatedItem = CartItem(
        itemId: existingItem.itemId,
        selectedQuantity: existingItem.selectedQuantity + cartItem.selectedQuantity,
      );
      
      await updateCartItemQuantity(
        userId: userId,
        cartItem: updatedItem,
        inventoryItem: resolvedInventoryItems.firstWhere(
          (item) => item.id.toString() == cartItem.itemId
        ),
      );
    } else {
      // Item doesn't exist - add new
      await cartRepository.addCartItem(userId, cartItem);
    }
    
    await fetchCartItems(userId);
  } catch (e) {
    Get.snackbar(
      "Error",
      "Failed to add item to cart: ${e.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    rethrow; // Rethrow to handle in the widget
  } finally {
    isProcessing.value = false;
  }
}

  Future<void> fetchCartItems(String userId) async {
    try {
      isLoading.value = true;
      print("Fetching cart for userId: $userId");

      final cartDoc = await FirebaseFirestore.instance.collection('carts').doc(userId).get();

      if (!cartDoc.exists) {
        print("No cart found for userId: $userId");
        cartItems.clear();
        resolvedInventoryItems.clear();
        return;
      }

      final List items = cartDoc.data()?['items'] ?? [];
      final List<CartItem> fetchedCartItems = items.map((item) => CartItem.fromJson(item)).toList();
      cartItems.assignAll(fetchedCartItems);

      final List<InventoryItem> fetchedInventoryItems = [];
      for (var cartItem in fetchedCartItems) {
        // print("Fetching inventory item for itemId: ${cartItem.itemId}");

        final inventoryDoc = await FirebaseFirestore.instance
            .collection('inventory_items')
            .where('id', isEqualTo: int.parse(cartItem.itemId))
            .limit(1)
            .get();

        if (inventoryDoc.docs.isNotEmpty) {
          fetchedInventoryItems.add(InventoryItem.fromJson(inventoryDoc.docs.first.data()));
        } else {
          print("Inventory item not found for itemId: ${cartItem.itemId}");
        }
      }

      resolvedInventoryItems.assignAll(fetchedInventoryItems);
    } catch (e) {
      print("Error fetching cart items: $e");
      Get.snackbar("Error", "Failed to load cart items: $e");
    } finally {
      isLoading.value = false;
    }
  }

Future<void> updateCartItemQuantity({
  required String userId,
  required CartItem cartItem,
  required InventoryItem inventoryItem,
}) async {
  try {
    isProcessing.value = true;

    if (cartItem.selectedQuantity > inventoryItem.quantity) {
      Get.snackbar(
        'Stock Limit',
        'Cannot add more than ${inventoryItem.quantity} items to the cart.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await cartRepository.updateCartItem(userId, cartItem);
    fetchCartItems(userId); // Refresh cart to ensure consistency
  } catch (e) {
    Get.snackbar('Error', 'Failed to update cart: ${e.toString()}');
  } finally {
    isProcessing.value = false;
  }
}

Future<void> removeItemFromCart({required String userId, required String cartItemId}) async {
  try {
    print("══════════════════════════════════════");
    print("⚡ Starting removeItemFromCart operation");
    print("ℹ User ID: $userId");
    print("ℹ Cart Item ID: $cartItemId");

    // Debug print local cart items before operation
    print("\n🛒 Local cart items BEFORE removal:");
    cartItems.forEach((item) => print(" - ${item.itemId}"));

    // Get the current cart document
    print("\n📡 Fetching cart document from Firestore...");
    final cartDoc = await FirebaseFirestore.instance
        .collection('carts')
        .doc(userId)
        .get();

    if (!cartDoc.exists) {
      print("❌ Cart document not found in Firestore");
      throw Exception("Cart document not found");
    }

    print("\n📄 Firestore document data:");
    print(cartDoc.data());

    final dynamic itemsData = cartDoc.data()?['items'];
    print("\n🔍 Items data type: ${itemsData.runtimeType}");
    
    if (itemsData is List) {
      print("\n🔄 Processing as LIST structure");
      final List<dynamic> itemsList = List.from(itemsData);
      print("ℹ Original items count: ${itemsList.length}");
      
      itemsList.removeWhere((item) {
        print(" - Checking item: ${item['item_id']} vs $cartItemId");
        return item['item_id'] == cartItemId;
      });
      
      print("ℹ Items after removal: ${itemsList.length}");
      print("ℹ Updated items list: $itemsList");
      
      print("\n📤 Updating Firestore with new list...");
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .update({'items': itemsList});
          
    } else if (itemsData is Map) {
      print("\n🔄 Processing as MAP structure");
      final Map<String, dynamic> itemsMap = Map.from(itemsData);
      print("ℹ Original items count: ${itemsMap.length}");
      
      itemsMap.removeWhere((key, value) {
        print(" - Checking item ${value['item_id']} at key $key");
        return value['item_id'] == cartItemId;
      });
      
      print("ℹ Items after removal: ${itemsMap.length}");
      print("ℹ Updated items map: $itemsMap");
      
      print("\n📤 Updating Firestore with new map...");
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .update({'items': itemsMap});
    } else {
      print("❌ Unexpected items format: ${itemsData.runtimeType}");
      throw Exception("Invalid items format in cart document");
    }

    // Update local cartItems list
    print("\n🔄 Updating local cart items...");
    cartItems.removeWhere((item) => item.itemId == cartItemId);
    print("ℹ Local cart items AFTER removal:");
    cartItems.forEach((item) => print(" - ${item.itemId}"));

    print("\n✅ Successfully removed item from cart");
    Get.snackbar('Success', 'Item removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  } catch (e, stackTrace) {
    print("\n❌❌❌ ERROR OCCURRED ❌❌❌");
    print("🔥 Error type: ${e.runtimeType}");
    print("🔥 Error message: $e");
    print("\n🔍 Stack trace:");
    print(stackTrace);
    
    if (e is FirebaseException) {
      print("\n🔥 Firebase error details:");
      print(" - Code: ${e.code}");
      print(" - Message: ${e.message}");
      print(" - Stacktrace: ${e.stackTrace}");
    }
    
    Get.snackbar('Error', 'Failed to remove item: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
  } finally {
    print("══════════════════════════════════════\n");
  }
}

// In CartController:
Future<void> submitRequest({
  required String userId,
  required String purpose,
  required int duration,
}) async {
  try {
    // Show a loading indicator
    isProcessing.value = true;
    print("🚀 Starting request submission...");
    print("User ID: $userId");
    print("Purpose: $purpose");
    print("Duration: $duration days");

    // Prepare the cart items for the request
    print("🛒 Preparing cart items for the request...");
    List<Map<String, dynamic>> cartItemsForRequest = cartItems.map((cartItem) {
      print("Item ID: ${cartItem.itemId}, Quantity: ${cartItem.selectedQuantity}");
      return {
        'item_id': cartItem.itemId,
        'selected_quantity': cartItem.selectedQuantity,
      };
    }).toList();

    // Debug the prepared cart items
    print("Prepared cart items: $cartItemsForRequest");

    // Fetch resolved cart items from the repository
    print("🔄 Resolving cart items...");
    List<Map<String, dynamic>> resolvedCartItems =
        await cartRepository.fetchResolvedCartItems(cartItemsForRequest);
    print("Resolved cart items: $resolvedCartItems");

    // Submit the request to Firestore
    print("📤 Storing request data to Firestore...");
    await cartRepository.storeRequestData(
      userId: userId,
      resolvedCartItems: resolvedCartItems,
      purpose: purpose,
      duration: duration,
    );
    print("✅ Request data successfully stored in Firestore!");

    // Delete the cart items after storing the request
    print("🗑️ Deleting cart for user: $userId...");
    await cartRepository.deleteCart(userId);
    print("✅ Cart deleted successfully!");

    // Notify the user of success
    print("🎉 Request submitted successfully!");
    Get.snackbar(
      'Success',
      'Request submitted successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  } catch (e, stackTrace) {
    // Debugging information
    print("❌ Failed to submit request");
    print("Error: $e");
    print("Stack trace: $stackTrace");

    // Notify the user of failure
    Get.snackbar(
      'Error',
      'Failed to submit request. Please try again later.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    // Hide the loading indicator
    isProcessing.value = false;
    print("🔚 Finished processing the request.");
  }
}

  void loadCartItems() async {
    isLoading(true);
    await Future.delayed(Duration(seconds: 2)); // Simulated delay
    cartItems.addAll([/* Populate with cart items */]);
    isLoading(false);
  }


  
final RxList<Map<String, dynamic>> pendingRequests = <Map<String, dynamic>>[].obs;
final RxList<Map<String, dynamic>> approvedRequests = <Map<String, dynamic>>[].obs;
final RxList<Map<String, dynamic>> declinedRequests = <Map<String, dynamic>>[].obs;

Future<void> fetchUserRequests(String userId) async {
  print('══════════════════════════════════════');
  print('⚡ Starting fetchUserRequests');
  print('ℹ User ID: $userId');
  
  try {
    print('\n🔄 Setting loading state to true');
    isLoading.value = true;

    print('\n🧹 Clearing existing requests');
    pendingRequests.clear();
    approvedRequests.clear();
    declinedRequests.clear();
    print('✔ Lists cleared');

    print('\n📡 Querying Firestore for requests...');
    final querySnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    print('✅ Firestore query completed');
    print('ℹ Number of documents retrieved: ${querySnapshot.docs.length}');

    for (var doc in querySnapshot.docs) {
      print('\n📄 Processing document ID: ${doc.id}');
      final requestData = doc.data() as Map<String, dynamic>;

      // Safeguard against missing or malformed data
      if (requestData.isEmpty) {
        print('⚠ Skipping empty document');
        continue;
      }

      final displayRequest = <String, dynamic>{'id': doc.id};
      displayRequest.addAll(requestData);

      // Handle cart_items
      final rawCartItems = requestData['cart_items'] ?? [];
      final cartItems = (rawCartItems is List)
          ? rawCartItems.whereType<Map>().toList()
          : [];

      if (cartItems.isNotEmpty) {
        displayRequest['cart_items'] = cartItems;
      }

      final status = displayRequest['approval_status']?.toString()?.toLowerCase() ?? 'pending';
      final typedRequest = Map<String, dynamic>.from(displayRequest);

      // Categorize requests
      switch (status) {
        case 'approved':
          approvedRequests.add(typedRequest);
          break;
        case 'declined':
          declinedRequests.add(typedRequest);
          break;
        default:
          pendingRequests.add(typedRequest);
      }
    }

    print('📊 Final request counts:');
    print(' - Pending: ${pendingRequests.length}');
    print(' - Approved: ${approvedRequests.length}');
    print(' - Declined: ${declinedRequests.length}');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('🔍 Stack trace:\n$stackTrace');
    Get.snackbar(
      "Error",
      "Failed to load requests: $e",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
    print('🔚 Done fetching requests');
    print('══════════════════════════════════════\n');
  }
}

  
}