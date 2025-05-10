import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';

class InventoryItemsRepository {
  static InventoryItemsRepository get instance => InventoryItemsRepository();

  // Firestore instance for database interactions.
  final _db = FirebaseFirestore.instance;

  /// Get all the 'inventory_items' collection documents
  Future<List<InventoryItem>> getAllInventoryItems() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _db.collection('inventory_items').get();
      return querySnapshot.docs
          .map((doc) => InventoryItem.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting inventory items: $e');
      return [];
    }
  }

  Future<List<InventoryItem>> getFavouriteProducts(List<String> productIds) async {
    try {
      if (productIds.isEmpty) return []; // Return early if the list is empty
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await _db.collection('inventory_items').where(FieldPath.documentId, whereIn: productIds).get();
      return querySnapshot.docs
          .map((doc) => InventoryItem.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error getting inventory items: $e');
      return [];
    }
  }

  /// Add a new item to the 'inventory_items' collection
  Future<void> addInventoryItem(InventoryItem newItem) async {
    try {
      await _db.collection('inventory_items').add(newItem.toJson());
      print('Item added successfully');
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  /// Update an existing inventory item
  Future<void> updateInventoryItem(String id, InventoryItem updatedItem) async {
    try {
      await _db.collection('inventory_items').doc(id).update(updatedItem.toJson());
      print('Item updated successfully');
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  /// Delete an inventory item by its document ID
  Future<void> deleteInventoryItem(String id) async {
    try {
      await _db.collection('inventory_items').doc(id).delete();
      print('Item deleted successfully');
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Stream<QuerySnapshot> listenToInventoryChanges() {
  return FirebaseFirestore.instance.collection('inventory_items').snapshots();
}

}
