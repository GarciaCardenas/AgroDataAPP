import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'custom_drawer.dart'; // 👈 Asegúrate de que el path sea correcto

class CultivoScreen extends StatelessWidget {
  const CultivoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context), // <- Añade el drawer aquí
      appBar: AppBar(
        title: const Text("Elije tu cultivo"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Elije tu cultivo", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(cropType: "naranja"),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/naranja.jpg'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Calcular producción"),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(cropType: "papa"),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/papa.jpg'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Detectar enfermedad"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text("¿No encuentras tu cultivo?", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: const [
                Icon(Icons.people, size: 40),
                Text("Pregúntale a la comunidad"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
