// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart';
import 'sales_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward(); // Inicia la animación al cargar
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddProductPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Desde la derecha
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.fileInvoice),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SalesHistoryPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0); // Desde abajo
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                        position: offsetAnimation, child: child);
                  },
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: Colors.blueGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: productBox.listenable(),
              builder: (context, Box<Product> box, _) {
                final allProducts = box.values.toList();

                if (allProducts.isEmpty) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeIn,
                    ),
                    child: Center(
                      child: Text(
                        'No hay productos registrados.',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }

                final filteredProducts = allProducts
                    .where((product) =>
                        product.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron productos con "$_searchQuery".',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5), // Desde abajo
                        end: Offset.zero, // En su lugar
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      )),
                      child: ProductCard(
                        product: product,
                        onDelete: () {
                          product.delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Producto "${product.name}" eliminado.',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(10),
                            ),
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
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(10),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Stock insuficiente para realizar la venta.',
                                ),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(10),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
