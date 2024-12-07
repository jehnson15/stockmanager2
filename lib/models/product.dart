import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double purchasePrice;

  @HiveField(2)
  double sellingPrice;

  @HiveField(3)
  int stock;

  Product({
    required this.name,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stock,
  });
}
