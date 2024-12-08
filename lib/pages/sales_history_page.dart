import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sale.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({Key? key}) : super(key: key);

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward(); // Iniciar la animación al cargar
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salesBox = Hive.box<Sale>('sales');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Historial de Ventas',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: ValueListenableBuilder(
        valueListenable: salesBox.listenable(),
        builder: (context, Box<Sale> box, _) {
          if (box.isEmpty) {
            return Center(
              child: FadeTransition(
                opacity: _animationController,
                child: Text(
                  'No hay ventas registradas.',
                  style:
                      GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            );
          }

          // Ordenar las ventas por fecha (más recientes primero)
          final sales = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2), // Comienza desde abajo
                  end: Offset.zero, // Termina en su lugar
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                )),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      sale.productName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${sale.quantity}'),
                        Text(
                            'Total: Lps. ${sale.totalPrice.toStringAsFixed(2)}'),
                        Text(
                          'Fecha: ${sale.date.day}/${sale.date.month}/${sale.date.year}',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
