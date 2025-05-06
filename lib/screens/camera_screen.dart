import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final String cropType;
  const CameraScreen({super.key, required this.cropType});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final picker = ImagePicker();
  String? _apiResponse;
  bool _isLoading = false;

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });

      await _sendToAPI(_image!);
    }
  }

  Future<void> _sendToAPI(File image) async {
    final uri = Uri.parse(
      widget.cropType == "naranja"
          ? 'https://your-api.com/calcular-produccion'
          : 'https://your-api.com/detectar-enfermedad',
    );

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    setState(() {
      _apiResponse = responseBody;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cropType == "naranja" ? 'Calcular producción' : 'Detectar enfermedad')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _image == null
                  ? const Text("Aún no has tomado una foto")
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(_image!),
                  const SizedBox(height: 10),
                  Text(_apiResponse ?? ''),
                ],
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _getImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Tomar Foto"),
          ),
        ],
      ),
    );
  }
}
