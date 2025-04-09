import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bienvenido")),
      body: Column(
        children: [
          Expanded(child: Image.asset('assets/farmer.jpg', fit: BoxFit.cover)),
          Text("Bienvenido", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
        ],
      ),
    );
  }
}
