import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final String cropType;
  final String mode; // "photo" o "video"

  const CameraScreen({
    super.key,
    required this.cropType,
    required this.mode,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _file;
  final picker = ImagePicker();
  String? _apiResponse;
  bool _isLoading = false;

  Future<void> _getFile() async {
    XFile? pickedFile;

    if (widget.mode == "photo") {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    } else if (widget.mode == "video") {
      pickedFile = await picker.pickVideo(source: ImageSource.camera);
    }

    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile!.path);
        _isLoading = true;
      });

      await _sendToAPI(_file!);
    }
  }

  Future<void> _sendToAPI(File file) async {
    final uri = Uri.parse(
      widget.cropType == "naranja"
          ? 'https://your-api.com/calcular-produccion'
          : 'https://your-api.com/detectar-enfermedad',
    );

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        widget.mode == "photo" ? 'image' : 'video',
        file.path,
      ));

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
      appBar: AppBar(
        title: Text(widget.cropType == "naranja" ? 'Calcular producción' : 'Detectar enfermedad'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _file == null
                  ? Text("Aún no has tomado una ${widget.mode == "photo" ? 'foto' : 'video'}")
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.mode == "photo"
                      ? Image.file(_file!)
                      : const Icon(Icons.videocam, size: 100),
                  const SizedBox(height: 10),
                  Text(_apiResponse ?? ''),
                ],
              ),

            ),
          ),
          ElevatedButton.icon(
            onPressed: _getFile,
            icon: Icon(widget.mode == "photo" ? Icons.camera_alt : Icons.videocam),
            label: Text(widget.mode == "photo" ? "Tomar Foto" : "Grabar Video"),
          ),
        ],
      ),
    );
  }
}
