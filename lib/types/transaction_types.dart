class Transaction {
  final String karat;
  final String id;
  final DateTime date;
  final double todayRate;
  final double weight;
  final double specificGravity;
  final double totalAmount;
  final bool isCompleted;
  final String settingId;

  const Transaction({
    required this.karat,
    required this.id,
    required this.date,
    required this.specificGravity,
    required this.todayRate,
    required this.totalAmount,
    required this.weight,
    required this.isCompleted,
    required this.settingId,
  });
}
