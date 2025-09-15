import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cultivo_screen.dart';
import 'screens/opciones_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/resultado_screen.dart';
import 'screens/comunidad_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/ayuda_screen.dart';
import 'screens/ajustes_screen.dart';
import 'screens/nosotros_screen.dart';
import 'screens/new_posts_creen.dart';
import 'screens/productos_screen.dart';
import 'screens/calcular_produccion_screen.dart';
import 'screens/detectar_enfermedad_screen.dart';
import 'screens/photo_screen.dart';
import 'screens/confirm_screen.dart';
import 'screens/result_screen.dart';
import 'screens/identification_result.dart';
import 'screens/form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final tieneUsuarioGuardado = prefs.getString('savedUsername') != null;

  runApp(MyApp(
    initialRoute: tieneUsuarioGuardado ? '/login' : '/register',
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroData App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/cultivo': (context) => CultivoScreen(),
        '/opciones': (context) => OpcionesScreen(),
        '/resultado': (context) => ResultadoScreen(),
        '/comunidad': (context) => ComunidadScreen(),
        '/perfil': (context) => PerfilScreen(),
        '/ayuda': (context) => AyudaScreen(),
        '/ajustes': (context) => AjustesScreen(),
        '/nosotros': (context) => NosotrosScreen(),
        '/new_post': (context) => NewPostScreen(),
        '/productos': (context) => ProductosScreen(),
        '/calcularProduccion': (context) => CalcularProduccionScreen(),
        '/detectarEnfermedad': (context) => DetectarEnfermedadScreen(),
        '/photo': (context) => PhotoScreen(),
        '/registro_cultivos': (context) => RegistroCultivosScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/camera':
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (context) => CameraScreen(
                cropType: args['cropType']!,
                mode: args['mode']!,
              ),
            );
          case '/confirm':
            final base64Image = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ConfirmScreen(base64Image: base64Image),
            );
          case '/result_api':
            final result = settings.arguments as IdentificationResult;
            return MaterialPageRoute(
              builder: (context) => ResultScreen(result: result),
            );
          default:
            return null;
        }
      },
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
