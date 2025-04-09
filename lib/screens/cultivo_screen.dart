import 'package:flutter/material.dart';

class CultivoScreen extends StatelessWidget {
  const CultivoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Elige tu cultivo")),
      body: Column(
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Image.asset('assets/naranja.png', width: 80),
                  Text("Naranja"),
                ],
              ),
              Column(
                children: [
                  Image.asset('assets/papa.png', width: 80),
                  Text("Papa"),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/comunidad');
            },
            child: Text("¿No encuentras tu cultivo? Pregúntale a la comunidad"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/opciones');
            },
            child: Text("Siguiente"),
          )
        ],
      ),
    );
  }
}
