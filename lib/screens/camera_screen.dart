import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrodata_application/widgets/BoxOverlay.dart';
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

  List<List<double>> _boxes = [];
  List<double> _scores = [];
  int _imgW = 1, _imgH = 1;

  Future<void> _pickFile(ImageSource source) async {
    XFile? pickedFile;

    if (widget.mode == "photo") {
      pickedFile = await picker.pickImage(source: source);
    } else {
      pickedFile = await picker.pickVideo(source: source);
    }

    if (pickedFile != null) {
      _file = File(pickedFile.path);
      if (widget.mode == "photo") {
        final decoded = await decodeImageFromList(await _file!.readAsBytes());
        _imgW = decoded.width;
        _imgH = decoded.height;
      }

      setState(() {
        _isLoading = true;
      });

      await _sendToAPI(_file!);
    }
  }

  Future<void> _sendToAPI(File file) async {
    final bytes = await file.readAsBytes();
    final b64 = base64Encode(bytes);

    final uri = Uri.parse(
      widget.cropType == "naranja"
          ? 'https://agrodata.servehttp.com/score'
          : 'https://your-api.com/detectar-enfermedad',
    );

    try {
      String responseBody = '';
      if (widget.cropType == "naranja") {
        final resp = await http
            .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'image': b64}),
        )
            .timeout(const Duration(seconds: 30));

        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        _boxes = (data['boxes'] as List)
            .map<List<double>>((b) => (b as List)
            .map((v) => v.toDouble())
            .toList()
            .cast<double>())
            .toList();
        _scores = (data['scores'] as List)
            .map<double>((s) => s.toDouble())
            .toList();
        final int n = (data['boxes'] as List).length;
        responseBody = 'Número de frutos detectados: $n';
      } else {
        final request = http.MultipartRequest('POST', uri)
          ..files.add(await http.MultipartFile.fromPath(
            widget.mode == "photo" ? 'image' : 'video',
            file.path,
          ));

        final response = await request.send();
        responseBody = await response.stream.bytesToString();
      }

      setState(() {
        _apiResponse = responseBody;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esFoto = widget.mode == "photo";
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cropType == "naranja"
            ? 'Calcular producción'
            : 'Detectar enfermedad'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _file == null
                  ? Text("Aún no has tomado ni seleccionado una ${esFoto ? 'foto' : 'video'}")
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  esFoto
                      ? Image.file(_file!)
                      : const Icon(Icons.videocam, size: 100),
                  const SizedBox(height: 10),
                  Text(_apiResponse ?? ''),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickFile(ImageSource.camera),
                icon: Icon(esFoto ? Icons.camera_alt : Icons.videocam),
                label: Text(esFoto ? "Tomar Foto" : "Grabar Video"),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickFile(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: Text(esFoto ? "Seleccionar Foto" : "Seleccionar Video"),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
