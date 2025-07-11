import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'translator.dart';
import 'identification_result.dart';

class ResultScreen extends StatefulWidget {
  final IdentificationResult result;
  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  bool _espanol = true;
  List<String> _tradCultivo = [];
  List<String> _tradEnfermedad = [];
  bool _cargando = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pretraducir();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _pretraducir() async {
    final crops = widget.result.crop.suggestions;
    final diseases = widget.result.disease.suggestions;

    _tradCultivo = await Future.wait(
      crops.map((s) => traducirDeepl(s.name, 'ES')),
    );
    _tradEnfermedad = await Future.wait(
      diseases.map((s) => traducirDeepl(s.name, 'ES')),
    );

    setState(() => _cargando = false);
  }

  Future<void> _abrirBusqueda(String cultivo, String enfermedad) async {
    final query =
        "cómo tratar la enfermedad $enfermedad en el cultivo de $cultivo";
    final url = Uri.parse("https://www.google.com/search?q=$query");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo abrir el navegador")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final crops = widget.result.crop.suggestions;
    final diseases = widget.result.disease.suggestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado'),
        actions: [
          Row(
            children: [
              Text(_espanol ? 'ES' : 'EN'),
              Switch(
                value: _espanol,
                onChanged: (v) => setState(() => _espanol = v),
              ),
            ],
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lista'),
            Tab(text: 'Gráficos'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildLista(crops, diseases),
          _buildGraficos(diseases),
        ],
      ),
    );
  }

  Widget _buildLista(List crops, List diseases) {
    final cultivoPrincipal = _espanol ? _tradCultivo.first : crops.first.name;
    final enfermedadPrincipal =
    _espanol ? _tradEnfermedad.first : diseases.first.name;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Cultivo:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ListTile(
          leading: const Icon(Icons.eco, color: Colors.green),
          title: Text(cultivoPrincipal),
        ),
        const SizedBox(height: 20),
        const Text('Enfermedades / Plagas:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ...List.generate(diseases.length, (i) {
          final name = _espanol ? _tradEnfermedad[i] : diseases[i].name;
          final prob = (diseases[i].probability * 100).toStringAsFixed(1);
          final esSaludable = name.toLowerCase().contains('healthy') ||
              name.toLowerCase().contains('saludable');
          return ListTile(
            leading: Icon(
              esSaludable ? Icons.favorite : Icons.bug_report,
              color: esSaludable ? Colors.green : Colors.red,
            ),
            title: Text(name),
            subtitle: Text('Probabilidad: $prob%'),
          );
        }),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text("Más información sobre tratamiento"),
          onPressed: () => _abrirBusqueda(
            (_espanol ? _tradCultivo.first : crops.first.name),
            (_espanol ? _tradEnfermedad.first : diseases.first.name),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildGraficos(List diseases) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("Distribución de Enfermedades",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: List.generate(diseases.length, (i) {
                  final name = _espanol
                      ? _tradEnfermedad[i]
                      : diseases[i].name;
                  final value = diseases[i].probability;
                  return PieChartSectionData(
                    color: Colors.primaries[i % Colors.primaries.length],
                    value: value,
                    title:
                    '${name}\n${(value * 100).toStringAsFixed(1)}%',
                    radius: 70,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
