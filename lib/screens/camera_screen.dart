import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

// 👇 Esta clase puede seguir siendo privada, ¡no hay problema!
class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      Navigator.pushNamed(context, '/resultado', arguments: _image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear planta')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _image == null
                  ? Text("Aún no has tomado una foto")
                  : Image.file(_image!),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _getImage,
            icon: Icon(Icons.camera_alt),
            label: Text("Tomar Foto"),
          ),
        ],
      ),
    );
  }
}
