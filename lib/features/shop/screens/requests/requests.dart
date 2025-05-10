import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
import 'package:irl_inventory/features/shop/controllers/cart_item_controller.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:irl_inventory/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:iconsax/iconsax.dart';

class Requests extends StatelessWidget {
  const Requests({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());
    final userController = Get.find<UserController>();
    final userId = userController.user.value.id!;

    Future.microtask(() => cartController.fetchUserRequests(userId));
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'Requests',
        //     style: Theme.of(context).textTheme.headlineMedium,
        //   ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Iconsax.refresh),
          //     onPressed: () => cartController.fetchUserRequests(userId),
          //   ),
          // ],
        // ),

        appBar: AppBar(
        title: Text('Requests', style: Theme.of(context).textTheme.headlineSmall),
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
              onPressed: () => cartController.fetchUserRequests(userId),
            ),
          ],
      ),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      isScrollable: false,
                      indicatorColor: TColors.primary,
                      labelColor: TColors.primary,
                      unselectedLabelColor: TColors.darkGrey,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(child: Text('Pending')),
                        Tab(child: Text('Approved')),
                        Tab(child: Text('Declined')),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Obx(() {
            if (cartController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Safely get lists with defensive copying
            final pending = List<Map<String, dynamic>>.from(cartController.pendingRequests);
            final approved = List<Map<String, dynamic>>.from(cartController.approvedRequests);
            final declined = List<Map<String, dynamic>>.from(cartController.declinedRequests);
            
            return TabBarView(
              children: [
                _buildRequestList(pending),
                _buildRequestList(approved),
                _buildRequestList(declined),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.note_remove, size: 48, color: TColors.darkGrey),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'No requests found',
              style: Theme.of(Get.context!).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) {
        final request = requests[index];
        final status = request['approval_status']?.toString() ?? 'Pending';
        final timestampRaw = request['timestamp'];
        DateTime? createdAt;

        // Safely handle `timestamp` as either a `Timestamp` or a `String`
        if (timestampRaw is Timestamp) {
          createdAt = timestampRaw.toDate();
        } else if (timestampRaw is String) {
          try {
            createdAt = DateTime.parse(timestampRaw);
          } catch (e) {
            createdAt = null; // Gracefully handle invalid date strings
          }
        }

        // Format timestamp for human-readable display
        final formattedDate = createdAt != null
            ? "${createdAt.day}/${createdAt.month}/${createdAt.year}, ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}"
            : 'Unknown date';

        // Handle duration with a fallback to 'N/A'
        final duration = request['duration']?.toString() ?? 'N/A'; // Assuming `duration` is stored as an integer or a string

        // Safely handle cart_items
        final rawCartItems = request['cart_items'];
        List<Map<String, dynamic>> cartItems = [];
        if (rawCartItems is List) {
          cartItems = rawCartItems.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (rawCartItems is Map) {
          cartItems = [Map<String, dynamic>.from(rawCartItems)];
        }

        final statusStyle = _getStatusStyle(status);

        return TRoundedContainer(
          padding: const EdgeInsets.all(TSizes.md),
          backgroundColor: statusStyle['bgColor'] as Color,
          borderColor: (statusStyle['color'] as Color).withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with ID
              Text(
                'Request #${request['id']?.toString().substring(0, 8) ?? 'N/A'}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).textTheme.labelSmall?.color?.withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: TSizes.sm),

              // Purpose as title
              Text(
                request['purpose']?.toString() ?? 'No purpose specified',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: TSizes.sm),

              // Request made at timestamp
              Text(
                'Request made at: $formattedDate',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TColors.darkGrey,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: TSizes.sm),

              // Duration
              Text(
                'For Duration: $duration days',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TColors.darkGrey,
                    ),
              ),
              const SizedBox(height: TSizes.sm),

              // Items list with divider
              const Divider(height: 1),
              const SizedBox(height: TSizes.sm),
              ...cartItems.map((item) {
                final itemName = (item['name']?.toString() ?? 'Unknown item');
                final shortName = itemName.split(' ').take(4).join(' ');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          shortName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        'x${item['selected_quantity']?.toString() ?? '1'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Footer with status
              const SizedBox(height: TSizes.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.sm,
                    vertical: TSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (statusStyle['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(TSizes.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusStyle['icon'] as IconData,
                        size: 16,
                        color: statusStyle['color'] as Color,
                      ),
                      const SizedBox(width: TSizes.xs),
                      Text(
                        status,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: statusStyle['color'] as Color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    return {
      'Approved': {
        'color': Colors.green,
        'icon': Iconsax.tick_circle,
        'bgColor': Colors.green.withOpacity(0.1),
      },
      'Declined': {
        'color': Colors.red,
        'icon': Iconsax.close_circle,
        'bgColor': Colors.red.withOpacity(0.1),
      },
      'Pending': {
        'color': Colors.deepPurpleAccent,
        'icon': Iconsax.clock,
        'bgColor': Colors.deepPurpleAccent.withOpacity(0.1),
      },
    }[status] ?? {
      'color': TColors.grey,
      'icon': Iconsax.info_circle,
      'bgColor': TColors.grey.withOpacity(0.1),
    };
  }
}
