/// Wallet model for broker coin system.
class WalletModel {
  final double balance;
  final List<TransactionModel> transactions;

  WalletModel({
    required this.balance,
    this.transactions = const [],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] ?? 0).toDouble(),
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => TransactionModel.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class TransactionModel {
  final String id;
  final String type; // 'earn' or 'withdraw'
  final double amount;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB _id format
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    
    // Map backend transaction type (CREDIT/DEBIT) to app format (earn/withdraw)
    final backendType = json['type'] ?? '';
    final type = backendType == 'CREDIT' 
        ? 'earn' 
        : backendType == 'DEBIT' 
            ? 'withdraw' 
            : json['type'] ?? 'earn';
    
    return TransactionModel(
      id: id,
      type: type,
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['reason'] ?? json['description'] ?? '',
      date: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['date'] != null
              ? DateTime.parse(json['date'])
              : DateTime.now(),
    );
  }
}
