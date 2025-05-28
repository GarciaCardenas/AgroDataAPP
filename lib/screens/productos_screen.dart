import 'package:flutter/material.dart';

class ProductosScreen extends StatelessWidget {
  const ProductosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos disponibles'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ProductoCard(
            nombre: 'Calcular producción',
            descripcion: 'Estima la producción de tu cultivo.',
            imagen: 'assets/images/produccion.png',
            onTap: () {
              Navigator.pushNamed(context, '/calcularProduccion');
            },
          ),
          SizedBox(height: 16),
          ProductoCard(
            nombre: 'Detectar enfermedad',
            descripcion: 'Diagnostica posibles enfermedades.',
            imagen: 'assets/images/enfermedad.png',
            onTap: () {
              Navigator.pushNamed(context, '/detectarEnfermedad');
            },
          ),
        ],
      ),
    );
  }
}

class ProductoCard extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String imagen;
  final VoidCallback onTap;

  const ProductoCard({
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 100, // aproximadamente 2.5 cm en pantalla móvil
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagen,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nombre,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(Icons.star_border, size: 16, color: Colors.blue);
                      }),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
