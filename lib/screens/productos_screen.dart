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
            nombre: 'Estimación de producción',
            descripcion:
            'Escanea tu cultivo con imágenes o video y obtén un cálculo aproximado de la cantidad de producción esperada.',
            imagen: 'assets/images/produccion.png',
            onTap: () {
              Navigator.pushNamed(context, '/calcularProduccion');
            },
          ),
          SizedBox(height: 16),
          ProductoCard(
            nombre: 'Diagnóstico de enfermedades',
            descripcion:
            'Selecciona el cultivo y escanea la planta. La app identificará posibles enfermedades o problemas.',
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagen,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
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
