extension DateTimeExtensions on DateTime {
    static DateTime? tryParseSafe(String? date) {
        if (date == null) return null;
        return DateTime.tryParse(date);
    }
}