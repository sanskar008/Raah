/// Coin pack model for store items.
class CoinPackModel {
  final String id;
  final String name;
  final int coins;
  final double price;
  final int bonusCoins;
  final bool isActive;

  CoinPackModel({
    required this.id,
    required this.name,
    required this.coins,
    required this.price,
    this.bonusCoins = 0,
    this.isActive = true,
  });

  factory CoinPackModel.fromJson(Map<String, dynamic> json) {
    return CoinPackModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      coins: json['coins'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      bonusCoins: json['bonusCoins'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coins': coins,
      'price': price,
      'bonusCoins': bonusCoins,
      'isActive': isActive,
    };
  }

  int get totalCoins => coins + bonusCoins;
}
