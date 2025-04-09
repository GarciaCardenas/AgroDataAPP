import 'package:flutter/material.dart';

class ResultadoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resultado de la consulta")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "El Resultado de la Consulta es:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Probabilidad de 70% con enfermedad de..."),
            Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/comunidad');
              },
              child: Text("Preguntar a la comunidad"),
            ),
          ],
        ),
      ),
    );
  }
}
