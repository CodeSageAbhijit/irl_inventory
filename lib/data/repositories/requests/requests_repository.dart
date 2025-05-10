import 'package:cloud_firestore/cloud_firestore.dart';

class RequestRepository {
  final FirebaseFirestore _firestore;

  RequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Fetch original approved requests
  Future<List<Map<String, dynamic>>> fetchRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('requests')
          .where('user_id', isEqualTo: userId)
          .where('approval_status', isEqualTo: 'Approved')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching requests: $e');
      throw Exception('Failed to load requests');
    }
  }

  // Fetch existing return requests for a user
  Future<List<Map<String, dynamic>>> fetchReturnRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('return_requests')
          .where('user_id', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching return requests: $e');
      throw Exception('Failed to load return requests');
    }
  }

  // Create new return request
  Future<void> logReturnRequest(Map<String, dynamic> returnDetails) async {
    try {
      await _firestore.collection('return_requests').add({
        ...returnDetails,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging return request: $e');
      throw Exception('Failed to submit return request');
    }
  }

  // Update return request status (for admin)
  Future<void> updateReturnStatus(String requestId, String status) async {
    try {
      // Find the document with matching request_id
      final query = await _firestore
          .collection('return_requests')
          .where('request_id', isEqualTo: requestId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'status': status,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating return status: $e');
      throw Exception('Failed to update return status');
    }
  }

  // Optional: Get real-time updates on return requests
  Stream<List<Map<String, dynamic>>> watchReturnRequests(String userId) {
    return _firestore
        .collection('return_requests')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

   
}