import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'custom_drawer.dart';

class CalcularProduccionScreen extends StatelessWidget {
  const CalcularProduccionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: const Text("Calcular producción"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Selecciona el cultivo a analizar", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(cropType: "naranja", mode: "video"),
                  ),
                );
              },
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/naranja.jpg'),
                  ),
                  SizedBox(height: 8),
                  Text("Naranja", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text("¿Necesitas ayuda?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/comunidad');
              },
              child: Column(
                children: const [
                  Icon(Icons.people, size: 40),
                  Text("Pregúntale a la comunidad"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
