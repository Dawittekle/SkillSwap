import 'package:cloud_firestore/cloud_firestore.dart';

// Shared access point for Firestore. Repositories keep the collection logic.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;
}
