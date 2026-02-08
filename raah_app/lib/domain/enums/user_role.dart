/// Three user roles in Raah — each gets a different dashboard.
enum UserRole {
  customer('customer', 'Customer'),
  broker('broker', 'Broker'),
  owner('owner', 'Room Owner');

  final String value;
  final String label;

  const UserRole(this.value, this.label);

  /// Parse role from API string
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value.toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }
}
