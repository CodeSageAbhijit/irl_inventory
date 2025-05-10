import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/data/repositories/inventory_items/inventory_items_repository.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/helpers/helper_functions.dart';
// import 'package:irl_inventory/data/repositories/product/product_repository.dart';
// import 'package:irl_inventory/features/shop/models/product_model.dart';
// import 'package:irl_inventory/utils/loaders/loaders.dart';
// import 'package:irl_inventory/utils/local_storage/local_storage.dart';
import 'package:irl_inventory/utils/local_storage/storage_utility.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  // Observable map to store favorites (productId: isFavourite)
  final isLoading = false.obs;
  final favorites = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initFavorites();
  }

  /// Initialize favorites by reading from local storage
  void initFavorites() {
    final json = LocalStorage.instance().readData<String>('favorites');
    if (json != null) {
      final storedFavorites = jsonDecode(json) as Map<String, dynamic>;
      favorites.assignAll(storedFavorites.map((key, value) => MapEntry(key, value as bool)));
    }
  }

  /// Check if a product is favorite
  bool isFavourite(String productId) {
    return favorites[productId] ?? false;
  }

  /// Toggle favorite status for a product
  void toggleFavoriteProduct(String productId) {
    if (!favorites.containsKey(productId)) {
      // Add to favorites
      favorites[productId] = true;
      saveFavoritesToStorage();
      customToast(message: 'Product has been added to your favorites.');
    } else {
      // Remove from favorites
      favorites.remove(productId);
      saveFavoritesToStorage();
      customToast(message: 'Product has been removed from your favorites.');
    }
    favorites.refresh(); // Update UI
  }

  /// Save favorites to local storage
  void saveFavoritesToStorage() {
    final encodedFavorites = json.encode(favorites);
    LocalStorage.instance().saveData('favorites', encodedFavorites);
  }

  /// Get list of favorite products
  Future<List<InventoryItem>> getFavoriteProducts() async {
    try {
      // Get product IDs from favorites map
      isLoading.value = true;
      final favoriteIds = favorites.keys.toList();

      if (favoriteIds.isEmpty) {
      return [];
    }
      
      // Fetch products from repository
      final response = await InventoryItemsRepository.instance.getFavouriteProducts(favoriteIds);
      if (response == null || response.isEmpty) {
      return []; // Return an empty list if response is null or empty
    }
      return response;
    } catch (e) {
      print('Failed to load favorite products');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all favorites
  void clearFavorites() {
    favorites.clear();
    LocalStorage.instance().removeData('favorites');
    customToast(message: 'Favorites cleared successfully');
    favorites.refresh();
  }

  Future<void> refreshFavorites() async {
    await getFavoriteProducts();
  }


  static customToast({required message}) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      elevation: 0,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: THelperFunctions.isDarkMode(Get.context!) ? TColors.darkerGrey.withOpacity(0.9) : TColors.grey.withOpacity(0.9),
        ), // BoxDecoration
        child: Center(child: Text(message, style: Theme.of(Get.context!).textTheme.labelLarge)),
      ), // Container
    ), // SnackBar
  );
}
}