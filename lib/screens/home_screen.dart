import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: Text("Inicio"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Bienvenido",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            // Imagen con altura limitada y adaptada
            Container(
              height: MediaQuery.of(context).size.height * 0.7, // 50% del alto de pantalla
              width: double.infinity,
              child: Image.asset(
                'assets/images/inicio.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cultivo');
                  },
                  icon: Icon(Icons.camera_alt),
                  label: Text("Escanear planta"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/comunidad');
                  },
                  icon: Icon(Icons.people),
                  label: Text("Ir a la comunidad"),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
