import 'package:flutter/material.dart';
import 'api_service.dart';
import 'result_screen.dart';
import 'dart:convert';

class ConfirmScreen extends StatelessWidget {
  final String base64Image;
  ConfirmScreen({required this.base64Image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirmar envío')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Image.memory(
                // decode for preview
                base64Decode(base64Image),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Enviar a Crop.health'),
              onPressed: () async {
                final result = await ApiService.identifyCrop([base64Image]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultScreen(result: result),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}