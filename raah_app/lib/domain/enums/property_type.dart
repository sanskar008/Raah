/// Property types available for listing.
enum PropertyType {
  room('room', 'Room'),
  flat('flat', 'Flat'),
  pg('pg', 'PG'),
  apartment('apartment', 'Apartment');

  final String value;
  final String label;

  const PropertyType(this.value, this.label);

  static PropertyType fromString(String value) {
    return PropertyType.values.firstWhere(
      (type) => type.value == value.toLowerCase(),
      orElse: () => PropertyType.room,
    );
  }
}
