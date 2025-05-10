import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/common/widgets/appbar/appbar.dart';
import 'package:irl_inventory/common/widgets/icons/circular_icon.dart';
import 'package:irl_inventory/common/widgets/layouts/grid_layout.dart';
import 'package:irl_inventory/common/widgets/loaders/vertical_shimmer.dart';
import 'package:irl_inventory/common/widgets/products/product_cards.dart/product_card.dart';
import 'package:irl_inventory/features/shop/controllers/favorite_controller.dart';
import 'package:irl_inventory/features/shop/controllers/inventory_items_controller.dart';
import 'package:irl_inventory/features/shop/models/inventory_item_model.dart';
import 'package:irl_inventory/features/shop/screens/home/home.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/navigation_menu.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/image_strings.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/common/widgets/loaders/animation_loader.dart';
// import 'package:irl_inventory/utils/helpers/cloud_helper_functions.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  final controller = FavouritesController.instance;
  late Future<List<InventoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = controller.getFavoriteProducts();
  }

  void _refreshWishlist() {
    setState(() {
      _future = controller.getFavoriteProducts(); // Trigger refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: TAppBar(
      //   title: Text(
      //     'Wishlist',
      //     style: Theme.of(context).textTheme.headlineMedium,
      //   ),
        
        
        // actions: [
        //   IconButton(
        //     icon: const Icon(Iconsax.refresh),
        //     onPressed: _refreshWishlist,
        //     tooltip: 'Refresh Wishlist',
        //   ),
        // ],
      // ),

      appBar: AppBar(
        title: Text('Wishlist', style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _refreshWishlist,
            tooltip: 'Refresh Wishlist',
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: FutureBuilder<List<InventoryItem>>(
            future: _future,
            builder: (context, snapshot) {
              // Nothing Found Widget
              final emptyWidget = Column(
                children: [
                  const SizedBox(height: 170,)
                  ,
                  EmptyStateWidget(
                    text: "Whoops! WishList is Empty...",
                    animation: TImages.verifyIllustration, // Provide the path to your image or animation
                    showAction: true,
                    actionText: 'Let\'s add some',
                    onActionPressed: () => Get.offAll(() => const NavigationMenu()),
                  ),
                ],
              );


              const loader = TVerticalProductShimmer(itemCount: 6);
              final widget = checkMultiRecordState(
                snapshot: snapshot,
                loader: loader,
                nothingFound: emptyWidget,
              );
              if (widget != null) return widget;

              final items = snapshot.data!;
              return TGridLayout(
                itemCount: items.length,
                itemBuilder: (_, index) => TProductCardVertical(item: items[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget? checkMultiRecordState<T>({
    required AsyncSnapshot<List<T>> snapshot,
    Widget? loader,
    Widget? error,
    Widget? nothingFound,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      if (loader != null) return loader;
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
      if (nothingFound != null) return nothingFound;
      return const Center(child: Text('No Data Found'));
    }

    if (snapshot.hasError) {
      if (error != null) return error;
      return const Center(child: Text('Something went wrong.'));
    }

    return null;
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String text;
  final String? animation; // Path to an image or animation
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    Key? key,
    required this.text,
    this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          if (animation != null)
            Image.asset(
              animation!,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
          const SizedBox(height: 20),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (showAction && actionText != null && onActionPressed != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // Button takes 70% of the screen width
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12), // Add vertical padding for better appearance
                  ),
                  child: Text(actionText!, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


