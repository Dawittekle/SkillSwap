import 'package:cloud_firestore/cloud_firestore.dart';

String readString(Map<String, dynamic> map, String key) {
  final value = map[key];
  return value is String ? value : '';
}

int readInt(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

double readDouble(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return 0;
}

bool readBool(Map<String, dynamic> map, String key) {
  final value = map[key];
  return value is bool ? value : false;
}

List<String> readStringList(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return [];
}

Map<String, String> readStringMap(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is Map) {
    return value.map((key, value) {
      return MapEntry(key.toString(), value?.toString() ?? '');
    });
  }
  return {};
}

DateTime readDateTime(Map<String, dynamic> map, String key) {
  final value = map[key];

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}

Timestamp dateTimeToTimestamp(DateTime value) {
  return Timestamp.fromDate(value);
}
