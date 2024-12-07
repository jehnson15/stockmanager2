import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/sale.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;
  final Function(int) onSell;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onDelete,
    required this.onSell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quantityController = TextEditingController();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del producto
                const FaIcon(
                  FontAwesomeIcons.boxOpen,
                  size: 40,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 16),
                // Detalles del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Precio de Venta: Lps. ${product.sellingPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.lato(
                            fontSize: 14, color: Colors.grey[700]),
                      ),
                      Text(
                        'Stock: ${product.stock} unidades',
                        style: GoogleFonts.lato(
                            fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                // Botón de eliminar
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.trashCan,
                      color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Campo de cantidad
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      prefixIcon: const FaIcon(FontAwesomeIcons.cartShopping),
                      labelText: 'Cantidad a Vender',
                      labelStyle: GoogleFonts.poppins(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blueGrey, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                // Botón de venta
                ElevatedButton(
                  onPressed: () {
                    final quantity = int.tryParse(quantityController.text) ?? 0;

                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Por favor ingresa una cantidad válida.'),
                        ),
                      );
                      return;
                    }

                    _registerSale(context, quantity);
                    quantityController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Vender',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar cuadro de confirmación para eliminar el producto
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const FaIcon(FontAwesomeIcons.trashCan, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Eliminar Producto',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${product.name}"?',
            style: GoogleFonts.lato(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  // Registrar la venta y actualizar el historial
  void _registerSale(BuildContext context, int quantity) {
    if (product.stock < quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock insuficiente para realizar la venta.'),
        ),
      );
      return;
    }

    // Reducir el stock
    product.stock -= quantity;
    product.save();

    // Registrar la venta en la caja 'sales'
    final salesBox = Hive.box<Sale>('sales');
    final sale = Sale(
      productName: product.name,
      quantity: quantity,
      totalPrice: product.sellingPrice * quantity,
      date: DateTime.now(),
    );
    salesBox.add(sale);

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Venta registrada: $quantity unidades de ${product.name}'),
      ),
    );
  }
}
