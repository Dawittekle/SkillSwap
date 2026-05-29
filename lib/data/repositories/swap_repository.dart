import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/data/repositories/firestore_repository_helpers.dart';

class SwapRepository {
  SwapRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _swapRequests {
    return _firestore.collection('swapRequests');
  }

  Future<String> createSwapRequest(SwapRequest request) async {
    try {
      final document = request.id.isEmpty
          ? _swapRequests.doc()
          : _swapRequests.doc(request.id);
      final requestToSave = request.id.isEmpty
          ? request.copyWith(id: document.id)
          : request;

      await document.set(requestToSave.toMap());
      return document.id;
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not create swap request.');
    }
  }

  Future<SwapRequest?> findActiveRequest({
    required String fromUserId,
    required String toUserId,
    required String wantedSkillId,
  }) async {
    try {
      final snapshot = await _swapRequests
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('wantedSkillId', isEqualTo: wantedSkillId)
          .get();

      final requests = _requestsFromSnapshot(snapshot);
      for (final request in requests) {
        if (request.status == 'pending' || request.status == 'accepted') {
          return request;
        }
      }

      return null;
    } catch (error) {
      throw friendlyFirestoreException(
        error,
        'Could not check existing swap requests.',
      );
    }
  }

  Stream<List<SwapRequest>> watchIncomingRequests(String uid) {
    return _swapRequests
        .where('toUserId', isEqualTo: uid)
        .snapshots()
        .map(_requestsFromSnapshot)
        .handleError((Object error) {
          throw friendlyFirestoreException(
            error,
            'Could not load incoming requests.',
          );
        });
  }

  Stream<List<SwapRequest>> watchOutgoingRequests(String uid) {
    return _swapRequests
        .where('fromUserId', isEqualTo: uid)
        .snapshots()
        .map(_requestsFromSnapshot)
        .handleError((Object error) {
          throw friendlyFirestoreException(
            error,
            'Could not load outgoing requests.',
          );
        });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _swapRequests.doc(requestId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not update swap request.');
    }
  }

  List<SwapRequest> _requestsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((document) {
      return SwapRequest.fromMap(dataWithDocumentId(document, 'id'));
    }).toList();
  }
}
