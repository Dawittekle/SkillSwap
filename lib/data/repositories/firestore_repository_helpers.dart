import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/data/firebase_error_messages.dart';

Map<String, dynamic> dataWithDocumentId(
  DocumentSnapshot<Map<String, dynamic>> document,
  String idFieldName,
) {
  final data = document.data() ?? {};

  return {
    ...data,
    if (data[idFieldName] == null || data[idFieldName] == '')
      idFieldName: document.id,
  };
}

Map<String, dynamic> firestoreUpdateData(Map<String, dynamic> data) {
  return data.map((key, value) {
    if (value is DateTime) {
      return MapEntry(key, Timestamp.fromDate(value));
    }

    return MapEntry(key, value);
  });
}

Exception friendlyFirestoreException(Object error, String fallbackMessage) {
  if (error is FirebaseException) {
    return Exception(friendlyFirestoreErrorMessage(error));
  }

  return Exception(fallbackMessage);
}
