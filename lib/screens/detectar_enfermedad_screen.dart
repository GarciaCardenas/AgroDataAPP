import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'custom_drawer.dart';

class DetectarEnfermedadScreen extends StatelessWidget {
  const DetectarEnfermedadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: const Text("Detectar enfermedad"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Selecciona el cultivo a analizar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // 🥔 Cultivo Papa
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(cropType: "papa", mode: "photo"),
                  ),
                );
              },
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/papa.jpg'),
                  ),
                  SizedBox(height: 8),
                  Text("Tizón de Papa", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🌽 Otro cultivo
            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/photo',
                  arguments: {
                    'cropType': 'otro',
                    'mode': 'photo',
                  },
                );
              },
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/otro_cultivo.jpg'),
                  ),
                  SizedBox(height: 8),
                  Text("Otro cultivo", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text("¿Necesitas ayuda?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 🤝 Comunidad
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
