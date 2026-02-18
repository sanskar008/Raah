/// Rental plan model for property rental periods.
class RentalPlanModel {
  final int days;
  final String name;
  final double price;
  final String description;

  RentalPlanModel({
    required this.days,
    required this.name,
    required this.price,
    required this.description,
  });

  factory RentalPlanModel.fromJson(Map<String, dynamic> json) {
    return RentalPlanModel(
      days: json['days'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'name': name,
      'price': price,
      'description': description,
    };
  }
}
