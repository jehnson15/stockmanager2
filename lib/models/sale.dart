import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(
    typeId: 1) // Asegúrate de usar un ID único diferente del modelo Product
class Sale extends HiveObject {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double totalPrice;

  @HiveField(3)
  final DateTime date;

  Sale({
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });
}
