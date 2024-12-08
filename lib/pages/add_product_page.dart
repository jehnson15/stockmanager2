import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final stockController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    purchasePriceController.dispose();
    sellingPriceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Agregar Producto',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(nameController, 'Nombre', FontAwesomeIcons.box),
              const SizedBox(height: 16),
              _buildTextField(
                purchasePriceController,
                'Precio de Compra',
                FontAwesomeIcons.dollarSign,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                sellingPriceController,
                'Precio de Venta',
                FontAwesomeIcons.tags,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                stockController,
                'Cantidad a Agregar',
                FontAwesomeIcons.plus,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final purchasePrice =
                      double.tryParse(purchasePriceController.text) ?? 0.0;
                  final sellingPrice =
                      double.tryParse(sellingPriceController.text) ?? 0.0;
                  final stockToAdd = int.tryParse(stockController.text) ?? 0;

                  if (name.isEmpty || stockToAdd <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor completa todos los campos.'),
                      ),
                    );
                    return;
                  }

                  final productBox = Hive.box<Product>('products');
                  Product? existingProduct;
                  try {
                    existingProduct = productBox.values.firstWhere(
                      (product) =>
                          product.name.toLowerCase() == name.toLowerCase(),
                    );
                  } catch (_) {}

                  if (existingProduct != null) {
                    existingProduct.stock += stockToAdd;
                    existingProduct.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Stock actualizado para $name.')),
                    );
                  } else {
                    final product = Product(
                      name: name,
                      purchasePrice: purchasePrice,
                      sellingPrice: sellingPrice,
                      stock: stockToAdd,
                    );
                    productBox.add(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Producto $name agregado.')),
                    );
                  }

                  Navigator.pop(context, true); // Retroalimentación de éxito
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Producto',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return FadeTransition(
      opacity: _animationController,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: FaIcon(icon, color: Colors.blueGrey),
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey, width: 2),
          ),
        ),
      ),
    );
  }
}
