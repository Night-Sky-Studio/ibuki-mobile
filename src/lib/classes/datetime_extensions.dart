extension DateTimeExtensions on DateTime {
    static DateTime? tryParseSafe(dynamic date) {
        if (date == null) return null;
        if (date is DateTime) return date;
        if (date is String) return DateTime.tryParse(date);
        if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
        return null;
    }
}