import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'confirm_screen.dart';

class PhotoScreen extends StatefulWidget {
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccionar o tomar foto')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text('No hay imagen seleccionada')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Tomar foto'),
              onPressed: () => _getImage(ImageSource.camera),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Seleccionar galería'),
              onPressed: () => _getImage(ImageSource.gallery),
            ),
            if (_image != null)
              ElevatedButton(
                child: Text('Confirmar'),
                onPressed: () {
                  final bytes = _image!.readAsBytesSync();
                  final base64Image = base64Encode(bytes);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmScreen(base64Image: base64Image),
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