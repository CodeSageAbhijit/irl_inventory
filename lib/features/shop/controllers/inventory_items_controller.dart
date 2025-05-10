import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/data/repositories/inventory_items/inventory_items_repository.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';

class InventoryItemsController extends GetxController {
  static InventoryItemsController get instance => Get.find();

  final isLoading = false.obs;
  final inventoryItemsRepository = Get.put(InventoryItemsRepository());
  RxList<InventoryItem> items = <InventoryItem>[].obs;
  RxList<InventoryItem> filteredItems = <InventoryItem>[].obs;
  var searchText = ''.obs;


  @override
  void onInit() {
    fetchFeaturedProducts();
    super.onInit();
  }

  void fetchFeaturedProducts() async {
    try {
      // Show loader while loading Products
      isLoading.value = true;

      // Fetch Products
      final products = await inventoryItemsRepository.getAllInventoryItems();

      // Assign Products
      items.assignAll(products);
      filteredItems.assignAll(products);

    } catch (e) {
      Get.snackbar(
        "Error",
        "Oh snap! ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.yellow,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Listen for real-time updates
  void listenToInventoryUpdates() {
    inventoryItemsRepository.listenToInventoryChanges().listen((snapshot) {
      try {
        // Parse snapshot into a list of InventoryItem
        final updatedItems = snapshot.docs
            .map((doc) => InventoryItem.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
            .toList();

        // Update the items observable
        items.assignAll(updatedItems);
        filteredItems.assignAll(updatedItems);

      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to fetch real-time updates: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }

  void searchItems(String query) {
  searchText.value = query;
  if (query.isEmpty) {
    filteredItems.assignAll(items); // No query = show all
  } 
  else {
    filteredItems.assignAll(
      items.where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
    );
  }
}


  /// Add a new inventory item
  Future<void> addInventoryItem(InventoryItem item) async {
    try {
      await inventoryItemsRepository.addInventoryItem(item);
      fetchFeaturedProducts(); // Refresh items
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not add item: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Update an inventory item
  Future<void> updateInventoryItem(String id, InventoryItem updatedItem) async {
    try {
      await inventoryItemsRepository.updateInventoryItem(id, updatedItem);
      fetchFeaturedProducts(); // Refresh items
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not update item: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Delete an inventory item
  Future<void> deleteInventoryItem(String id) async {
    try {
      await inventoryItemsRepository.deleteInventoryItem(id);
      fetchFeaturedProducts(); // Refresh items
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not delete item: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
