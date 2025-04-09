import 'package:flutter/material.dart';

class OpcionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Opciones disponibles")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Aquí puedes añadir lógica para producción
              },
              child: Text("Calcular Producción"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              child: Text("Detectar enfermedad"),
            ),
          ],
        ),
      ),
    );
  }
}
