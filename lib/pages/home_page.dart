import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productBox = Hive.box<Product>('products');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'StockManager',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.plusCircle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No hay productos registrados.',
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final product = box.getAt(index);
              return ProductCard(
                product: product!,
                onDelete: () {
                  product.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado.')),
                  );
                },
                onSell: (quantity) {
                  if (product.stock >= quantity) {
                    product.stock -= quantity;
                    product.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Venta realizada: $quantity unidades de ${product.name}',
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Stock insuficiente para realizar la venta.'),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
