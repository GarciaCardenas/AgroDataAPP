import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'video_player_widget.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController contentController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  File? mediaFile;
  final ImagePicker _picker = ImagePicker();
  List<String> categorias = [];

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    final data = await DatabaseHelper.instance.obtenerCategorias();
    setState(() {
      categorias = data.map((e) => e['nombre'].toString()).toList();
    });
  }

  Future<void> pickMedia({required bool isVideo}) async {
    XFile? pickedFile;
    if (isVideo) {
      pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      setState(() {
        mediaFile = File(pickedFile!.path);
      });
    }
  }

  Future<void> guardarPost() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Escribe algo para publicar.")),
      );
      return;
    }

    // Verificar si la categoría existe
    String nombreCategoria = categoryController.text.trim();
    if (nombreCategoria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, escribe o selecciona una categoría.")),
      );
      return;
    }

    // Insertar si no existe
    int categoriaId = await DatabaseHelper.instance.insertarCategoria(nombreCategoria);

    final nuevoPost = {
      'user_id': userId,
      'contenido': contentController.text,
      'imagen': mediaFile?.path ?? '',
      'fecha': DateTime.now().toIso8601String(),
      'categoria_id': categoriaId,
    };

    await DatabaseHelper.instance.insertarPost(nuevoPost);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("¡Publicación guardada!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nueva publicación"), backgroundColor: Colors.green),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "¿Qué estás pensando?",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              /// CAMPO DE CATEGORÍA CON AUTOCOMPLETE
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') return const Iterable<String>.empty();
                  return categorias.where((String option) =>
                      option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  categoryController.text = controller.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (value) => categoryController.text = value,
                    decoration: InputDecoration(
                      hintText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                onSelected: (String selection) {
                  categoryController.text = selection;
                },
              ),
              SizedBox(height: 20),

              if (mediaFile != null)
                Column(
                  children: [
                    mediaFile!.path.endsWith(".mp4")
                        ? SizedBox(
                      height: 500,
                      width: double.infinity,
                      child: VideoPlayerWidget(videoFile: mediaFile!),
                    )
                        : Image.file(mediaFile!, height: 500),
                    Text(mediaFile!.path.split('/').last),
                  ],
                ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => pickMedia(isVideo: false),
                    icon: Icon(Icons.image),
                    label: Text("Foto"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => pickMedia(isVideo: true),
                    icon: Icon(Icons.videocam),
                    label: Text("Video"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: guardarPost,
                icon: Icon(Icons.send),
                label: Text("Publicar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
