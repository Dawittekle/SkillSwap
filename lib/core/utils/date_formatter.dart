// Simple date helpers for showing demo-friendly dates and times.
class DateFormatter {
  const DateFormatter._();

  static String shortDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  static String shortTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $suffix';
  }
}
