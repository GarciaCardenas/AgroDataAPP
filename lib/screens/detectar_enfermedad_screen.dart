import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class DetectarEnfermedadScreen extends StatelessWidget {
  const DetectarEnfermedadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cultivos = [
      {'nombre': 'Papa', 'imagen': 'assets/images/papa.jpg'},
      {'nombre': 'Maíz', 'imagen': 'assets/images/maiz.jpg'},
      {'nombre': 'Café', 'imagen': 'assets/images/cafe.jpg'},
      {'nombre': 'Cebolla', 'imagen': 'assets/images/cebolla.jpg'},
      {'nombre': 'Tomate', 'imagen': 'assets/images/tomate.jpg'},
      {'nombre': 'Aguacate', 'imagen': 'assets/images/aguacate.jpg'},
      {'nombre': 'Plátano', 'imagen': 'assets/images/platano.jpg'},
      {'nombre': 'Soya', 'imagen': 'assets/images/soya.jpg'},
      {'nombre': 'Arroz', 'imagen': 'assets/images/arroz.jpg'},
      {'nombre': 'Trigo', 'imagen': 'assets/images/trigo.jpg'},
      {'nombre': 'Uva', 'imagen': 'assets/images/uva.jpg'},
      {'nombre': 'Otro cultivo', 'imagen': 'assets/images/otro_cultivo.jpg'},
    ];

    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: const Text("Detectar enfermedad"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Text(
              "Selecciona el cultivo a analizar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(height: 20),

          // Modern Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cultivos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final cultivo = cultivos[index];

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/photo',
                    arguments: {
                      'cropType': cultivo['nombre']!.toLowerCase(),
                      'mode': 'photo',
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.asset(
                          cultivo['imagen']!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                            child: Text(
                              cultivo['nombre']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          const Center(
            child: Text(
              "¿Necesitas ayuda?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/comunidad'),
              child: Column(
                children: const [
                  Icon(Icons.people, size: 40, color: Colors.green),
                  SizedBox(height: 5),
                  Text("Pregúntale a la comunidad"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
