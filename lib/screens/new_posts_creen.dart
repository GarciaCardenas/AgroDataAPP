import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController contentController = TextEditingController();
  File? mediaFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickMedia({required bool isVideo}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        mediaFile = File(pickedFile.path);
      });
    }
  }

  Future<void> guardarPost() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId != null && contentController.text.isNotEmpty) {
      final nuevoPost = {
        'user_id': userId,
        'contenido': contentController.text,
        'imagen': mediaFile?.path ?? '',
        'fecha': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper.instance.insertarPost(nuevoPost);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("¡Publicación guardada!")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Escribe algo para publicar.")),
      );
    }
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
              if (mediaFile != null)
                Column(
                  children: [
                    mediaFile!.path.endsWith(".mp4")
                        ? Icon(Icons.videocam, size: 100)
                        : Image.file(mediaFile!, height: 200),
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
