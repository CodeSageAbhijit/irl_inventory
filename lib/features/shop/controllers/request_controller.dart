import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:irl_inventory/data/repositories/requests/requests_repository.dart';
import 'package:irl_inventory/features/personalization/controllers/user_controller.dart';

class RequestController extends GetxController {
  final RequestRepository _repository;
  final String? userId; // Add userId as a class property
  
  // Approved requests from the original system
  final RxList<Map<String, dynamic>> approvedRequests = <Map<String, dynamic>>[].obs;
  
  // Track return requests and their statuses
  final RxMap<String, Map<String, dynamic>> returnRequests = <String, Map<String, dynamic>>{}.obs;

  RequestController({required RequestRepository repository, this.userId}) 
      : _repository = repository {
    // Initialize the stream listener
    ever(returnRequests, (_) => update());
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with current user
    final userController = Get.find<UserController>();
    final _userId = userController.user.value.id!;
    
    if (_userId != null) {
      // Fetch initial approved requests
      fetchApprovedRequests(_userId!);
      
      // Set up real-time listener for return requests
      _repository.watchReturnRequests(_userId!).listen((returnRequestsList) {
        // Convert list to map with request_id as key
        final newReturnRequests = <String, Map<String, dynamic>>{};
        for (final request in returnRequestsList) {
          if (request['request_id'] != null) {
            newReturnRequests[request['request_id']] = request;
          }
        }
        returnRequests.assignAll(newReturnRequests);
      });
    }
  }

  Future<void> fetchApprovedRequests(String userId) async {
    try {
      final fetchedRequests = await _repository.fetchRequests(userId);
      
      // Filter approved requests
      final filteredRequests = fetchedRequests
          .where((request) => request["approval_status"] == "Approved")
          .toList();
      
      approvedRequests.assignAll(filteredRequests);
      
      // Also fetch any existing return requests
      await _fetchReturnRequests(userId);
    } catch (e) {
      print('Error fetching requests: $e');
      Get.snackbar('Error', 'Failed to load requests');
    }
  }

  Future<void> _fetchReturnRequests(String userId) async {
    try {
      final returns = await _repository.fetchReturnRequests(userId);
      returnRequests.clear();
      for (var returnReq in returns) {
        if (returnReq['request_id'] != null) {
          returnRequests[returnReq['request_id']] = returnReq;
        }
      }
    } catch (e) {
      print('Error fetching return requests: $e');
    }
  }

  Future<void> logReturnRequest(Map<String, dynamic> returnDetails) async {
  // Log return request in Firebase
  await _repository.logReturnRequest(returnDetails);

  // Update local state
  final requestId = returnDetails["request_id"];
  final updatedRequests = approvedRequests.map((request) {
    if (request["request_id"] == requestId) {
      request["return_status"] = "pending"; // Update the local state
    }
    return request;
  }).toList();

  approvedRequests.assignAll(updatedRequests); // Reflect changes locally
}


  // Helper methods for UI
  bool isReturnRequested(String requestId) {
    return returnRequests.containsKey(requestId);
  }

  bool isReturnApproved(String requestId) {
    return returnRequests[requestId]?['status'] == 'approved';
  }

  String? getReturnStatus(String requestId) {
    return returnRequests[requestId]?['status'];
  }

  // Admin approval method
  Future<void> approveReturn(String requestId) async {
    try {
      await _repository.updateReturnStatus(requestId, 'approved');
      if (returnRequests.containsKey(requestId)) {
        returnRequests[requestId]?['status'] = 'approved';
        returnRequests.refresh(); // Force UI update
      }
    } catch (e) {
      print('Error approving return: $e');
      rethrow;
    }
  }
}