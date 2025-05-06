import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class NosotrosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: Text("Sobre Nosotros"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quiénes somos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            Text(
              "Somos una aplicación enfocada en brindar ayuda a agricultores mediante tecnología moderna. "
                  "Ofrecemos herramientas para escanear plantas, acceder a una comunidad y administrar cultivos fácilmente.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Text("Contacto", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(children: [Icon(Icons.email), SizedBox(width: 10), Text("soporte@agroapp.com")]),
            Row(children: [Icon(Icons.phone), SizedBox(width: 10), Text("+52 123 456 7890")]),
          ],
        ),
      ),
    );
  }
}
