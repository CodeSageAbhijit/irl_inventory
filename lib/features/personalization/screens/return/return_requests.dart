import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:irl_inventory/data/repositories/requests/requests_repository.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';
import 'package:irl_inventory/features/shop/controllers/request_controller.dart';
import 'package:irl_inventory/utils/constants/colors.dart';
import 'package:irl_inventory/utils/constants/sizes.dart';
import 'package:intl/intl.dart';

class ReturnItems extends StatelessWidget {
  final RequestController controller;

  ReturnItems({super.key})
      : controller = Get.put(RequestController(repository: RequestRepository())) {
    // Initialize the controller with the user ID when widget is created
    final userController = Get.find<UserController>();
    String userId = userController.user.value.id!;
    controller.fetchApprovedRequests(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Returns', style: Theme.of(context).textTheme.headlineSmall),
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
      ),
      body: Obx(() {
        final approvedRequests = controller.approvedRequests;

        if (approvedRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.box_remove, size: 48, color: TColors.darkGrey),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'No items available for return',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          itemCount: approvedRequests.length,
          separatorBuilder: (context, index) => const SizedBox(height: TSizes.spaceBtwSections),
          itemBuilder: (context, index) {
            final request = approvedRequests[index];
            final cartItems = request["cart_items"] as List<dynamic>;
            final requestId = request["request_id"];
            
            // Get return status for this request
            final returnStatus = controller.getReturnStatus(requestId);
            final isReturnRequested = returnStatus != null;
            final isReturnApproved = returnStatus == 'approved';
            
            // Calculate remaining time
            final timestamp = DateTime.parse(request["timestamp"]);
            final duration = request["duration"] as int;
            final endDate = timestamp.add(Duration(days: duration));
            final now = DateTime.now();
            final remaining = endDate.difference(now);
            final isExpired = remaining.isNegative;
            final remainingDays = remaining.inDays.abs();
            final remainingHours = remaining.inHours.remainder(24).abs();

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                color: TColors.white,
                boxShadow: [
                  BoxShadow(
                    color: TColors.darkGrey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                title: Text(
                  'Request #${requestId.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isExpired 
                        ? 'Expired ${remainingDays}d ago'
                        : 'Due in ${remainingDays}d ${remainingHours}h',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isExpired ? TColors.error : TColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                leading: Container(
                  padding: const EdgeInsets.all(TSizes.sm),
                  decoration: BoxDecoration(
                    color: isReturnApproved 
                      ? TColors.success.withOpacity(0.2)
                      : isReturnRequested
                        ? TColors.warning.withOpacity(0.2)
                        : isExpired 
                          ? TColors.error.withOpacity(0.2)
                          : TColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isReturnApproved 
                      ? Iconsax.tick_circle
                      : isReturnRequested
                        ? Iconsax.clock
                        : isExpired 
                          ? Iconsax.close_circle 
                          : Iconsax.receipt,
                    color: isReturnApproved 
                      ? TColors.success
                      : isReturnRequested
                        ? TColors.warning
                        : isExpired 
                          ? TColors.error 
                          : TColors.primary,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.defaultSpace,
                      vertical: TSizes.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Request Details
                        _buildDetailRow(
                          context,
                          icon: Iconsax.document_text,
                          label: 'Purpose',
                          value: request["purpose"],
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems / 2),
                        _buildDetailRow(
                          context,
                          icon: Iconsax.calendar,
                          label: 'Duration',
                          value: '${duration} days (${DateFormat('MMM dd').format(timestamp)} - ${DateFormat('MMM dd').format(endDate)})',
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        
                        // Items List
                        Text(
                          'ITEMS TO RETURN (${cartItems.length})',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        ...cartItems.map((item) => _buildReturnItemCard(
                          context, 
                          item: item,
                          requestId: requestId,
                          isExpired: isExpired,
                          isReturnRequested: isReturnRequested,
                          isReturnApproved: isReturnApproved,
                        )).toList(),
                        
                        // Return All Button
                        const SizedBox(height: TSizes.spaceBtwItems),
                        SizedBox(
                          width: double.infinity,
                          child: _buildReturnButton(
                            context,
                            requestId: requestId,
                            cartItems: cartItems,
                            isExpired: isExpired,
                            isReturnRequested: isReturnRequested,
                            isReturnApproved: isReturnApproved,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TColors.darkerGrey),
        const SizedBox(width: TSizes.spaceBtwItems / 2),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildReturnItemCard(
    BuildContext context, {
    required dynamic item,
    required String requestId,
    required bool isExpired,
    required bool isReturnRequested,
    required bool isReturnApproved,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      elevation: 0,
      color: TColors.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: isReturnApproved 
              ? TColors.success.withOpacity(0.1)
              : isReturnRequested
                ? TColors.warning.withOpacity(0.1)
                : isExpired 
                  ? TColors.error.withOpacity(0.1)
                  : TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
          ),
          child: Icon(
            isReturnApproved 
              ? Iconsax.tick_circle
              : isReturnRequested
                ? Iconsax.clock
                : Iconsax.box,
            color: isReturnApproved 
              ? TColors.success
              : isReturnRequested
                ? TColors.warning
                : isExpired 
                  ? TColors.error 
                  : TColors.primary,
          ),
        ),
        title: Text(
          item['name'],
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Qty: ${item['selected_quantity']}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: _buildReturnButton(
          context,
          requestId: requestId,
          cartItems: [item],
          isExpired: isExpired,
          isReturnRequested: isReturnRequested,
          isReturnApproved: isReturnApproved,
          isItemButton: true,
        ),
      ),
    );
  }

  Widget _buildReturnButton(
    BuildContext context, {
    required String requestId,
    required List<dynamic> cartItems,
    required bool isExpired,
    required bool isReturnRequested,
    required bool isReturnApproved,
    bool isItemButton = false,
  }) {
    final userController = Get.find<UserController>();
    final userId = userController.user.value.id!;
    final buttonText = isReturnApproved 
      ? 'Return Approved'
      : isReturnRequested
        ? 'Return Requested'
        : isExpired 
          ? 'Expired' 
          : 'Return';

    return ElevatedButton(
      onPressed: isExpired || isReturnRequested
        ? null
        : () async {
            final returnDetails = {
              "user_id": userId,
              "request_id": requestId,
              "items": cartItems,
              "timestamp": DateTime.now().toIso8601String(),
              "status": "pending",
            };
            await controller.logReturnRequest(returnDetails);
            Get.snackbar(
              'Success',
              'Return request submitted',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: TColors.success,
              colorText: TColors.white,
            );
          },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: isItemButton ? TSizes.sm : TSizes.md,
        ),
        backgroundColor: isReturnApproved 
          ? TColors.success
          : isReturnRequested
            ? TColors.warning
            : isExpired 
              ? TColors.grey 
              : TColors.primary,
        foregroundColor: TColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
        ),
      ),
      child: Text(
        buttonText,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: TColors.white,
        ),
      ),
    );
  }
}