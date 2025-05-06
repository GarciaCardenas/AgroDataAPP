import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class AjustesScreen extends StatefulWidget {
  @override
  _AjustesScreenState createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool notificaciones = true;
  bool modoOscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(context),
      appBar: AppBar(
        title: Text("Ajustes"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: Text("Notificaciones"),
            value: notificaciones,
            onChanged: (value) {
              setState(() {
                notificaciones = value;
              });
            },
          ),
          SwitchListTile(
            title: Text("Modo oscuro"),
            value: modoOscuro,
            onChanged: (value) {
              setState(() {
                modoOscuro = value;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text("Idioma"),
            subtitle: Text("Español"),
            onTap: () {
              // Aquí puedes mostrar un selector de idioma
            },
          ),
        ],
      ),
    );
  }
}
