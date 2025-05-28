import 'package:flutter/material.dart';
import 'identification_result.dart';

class ResultScreen extends StatelessWidget {
  final IdentificationResult result;
  ResultScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resultado')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Cultivo:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...result.crop.suggestions.map((s) => ListTile(
              title: Text(s.name),
              subtitle: Text('Probabilidad: ${(s.probability * 100).toStringAsFixed(1)}%'),
            )),
            SizedBox(height: 20),
            Text('Enfermedades / Plagas:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...result.disease.suggestions.map((s) => ListTile(
              title: Text(s.name),
              subtitle: Text('Probabilidad: ${(s.probability * 100).toStringAsFixed(1)}%'),
            )),
          ],
        ),
      ),
    );
  }
}
