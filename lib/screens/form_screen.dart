import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';
import 'dart:async';

class RegistroCultivosScreen extends StatefulWidget {
  @override
  _RegistroCultivosScreenState createState() => _RegistroCultivosScreenState();
}

class _RegistroCultivosScreenState extends State<RegistroCultivosScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> cultivos = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarCultivos();
  }

  Future<void> _cargarCultivos() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final data = await DatabaseHelper.instance.obtenerCultivosPorUsuario(userId);
      setState(() {
        cultivos = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Gestión de Cultivos",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "Mis Cultivos"),
            Tab(text: "Formulario Nuevo"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCultivosTab(),
          FormularioNuevoCultivo(onGuardado: () {
            _cargarCultivos();
            _tabController.animateTo(0);
          }),
        ],
      ),
    );
  }

  Widget _buildCultivosTab() {
    return Column(
      children: [
        // Header con estadísticas
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF66BB6A),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Control de Cultivos",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Registra y monitorea el progreso de tus cultivos",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Estadísticas
        Container(
          margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatColumn(Icons.grass, "Cultivos Activos", "${cultivos.length}"),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatColumn(Icons.trending_up, "En Crecimiento", "${cultivos.where((c) => c['estado'] == 'Crecimiento').length}"),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatColumn(Icons.check_circle, "Listos", "${cultivos.where((c) => c['estado'] == 'Cosecha').length}"),
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Lista de cultivos
        Expanded(
          child: cultivos.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: cultivos.length,
            itemBuilder: (context, index) => _buildCultivoCard(cultivos[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF4CAF50), size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "No hay cultivos registrados",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "¡Comienza registrando tu primer cultivo!",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultivoCard(Map<String, dynamic> cultivo) {
    Color statusColor = _getStatusColor(cultivo['estado']);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleCultivoScreen(cultivo: cultivo),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCultivoIcon(cultivo['tipo_cultivo']),
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cultivo['nombre'] ?? 'Cultivo sin nombre',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          cultivo['tipo_cultivo'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cultivo['estado'] ?? 'Sin estado',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(Icons.calendar_today, 'Plantado',
                        _formatDate(cultivo['fecha_siembra'])),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(Icons.straighten, 'Área',
                        '${cultivo['area'] ?? 0} m²'),
                  ),
                ],
              ),
              if (cultivo['notas'] != null && cultivo['notas'].isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  cultivo['notas'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? estado) {
    switch (estado) {
      case 'Siembra': return Colors.orange;
      case 'Crecimiento': return Colors.blue;
      case 'Floración': return Colors.purple;
      case 'Cosecha': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCultivoIcon(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'maíz': return Icons.grain;
      case 'tomate': return Icons.local_florist;
      case 'papa': return Icons.circle;
      case 'café': return Icons.coffee;
      case 'arroz': return Icons.grass;
      default: return Icons.agriculture;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Sin fecha';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Sin fecha';
    }
  }
}

class FormularioNuevoCultivo extends StatefulWidget {
  final VoidCallback onGuardado;

  const FormularioNuevoCultivo({required this.onGuardado});

  @override
  _FormularioNuevoCultivoState createState() => _FormularioNuevoCultivoState();
}

class _FormularioNuevoCultivoState extends State<FormularioNuevoCultivo> {
  final _formKey = GlobalKey<FormState>();

  // Variables para Speech to Text - CORREGIDAS
  late SpeechToText _speechToText;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  String _baseText = '';
  TextEditingController? _activeController;
  Timer? _speechTimer; // NUEVO: Timer para manejar timeout
  String _finalRecognizedText = ''; // NUEVO: Para guardar último resultado


  // Controllers
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _areaController = TextEditingController();
  final _notasController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _variedadController = TextEditingController();

  String _estadoSeleccionado = 'Siembra';
  DateTime _fechaSiembra = DateTime.now();

  List<String> _estados = ['Siembra', 'Crecimiento', 'Floración', 'Cosecha'];
  List<String> _tiposCultivo = [
    'Maíz', 'Tomate', 'Papa', 'Café', 'Arroz', 'Frijol', 'Cebolla', 'Lechuga', 'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Inicializar el speech to text
  void _initSpeech() async {
    try {
      _speechToText = SpeechToText();
      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          print('❌ Error en speech: ${error.errorMsg}');
          _handleSpeechEnd();
          _showErrorSnackBar('Error en reconocimiento de voz: ${error.errorMsg}');
        },
        onStatus: (status) {
          print('🔄 Status del speech: $status');
          if (status == 'done' || status == 'notListening') {
            // Dar un pequeño delay antes de finalizar para capturar última palabra
            _speechTimer?.cancel();
            _speechTimer = Timer(Duration(milliseconds: 500), () {
              _handleSpeechEnd();
            });
          }
        },
      );
      setState(() {});
    } catch (e) {
      print('❌ Error inicializando speech: $e');
      setState(() {
        _speechEnabled = false;
      });
    }
  }

  void _handleSpeechEnd() {
    if (_activeController != null && _finalRecognizedText.isNotEmpty) {
      // Asegurar que el texto final se guarde
      String finalText = _baseText.isEmpty ? _finalRecognizedText :
      (_baseText.endsWith(' ') ? _baseText + _finalRecognizedText : _baseText + ' ' + _finalRecognizedText);

      _activeController!.text = finalText;
      _activeController!.selection = TextSelection.fromPosition(
        TextPosition(offset: _activeController!.text.length),
      );

      print('✅ Texto final guardado: "$finalText"');
    }

    setState(() {
      _isListening = false;
      _activeController = null;
      _baseText = '';
      _finalRecognizedText = '';
    });

    _speechTimer?.cancel();
  }

  /// Iniciar la escucha de voz - VERSIÓN CORREGIDA
  void _startListening(TextEditingController controller) async {
    // Verificar permisos de micrófono
    PermissionStatus status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      _showErrorSnackBar('Permisos de micrófono denegados');
      return;
    }

    if (!_speechEnabled) {
      _showErrorSnackBar('Reconocimiento de voz no disponible');
      return;
    }

    // Cancelar timer anterior si existe
    _speechTimer?.cancel();

    // Guardar el texto base antes de empezar
    _baseText = controller.text;
    _finalRecognizedText = '';

    setState(() {
      _activeController = controller;
      _isListening = true;
      _lastWords = '';
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: "es_ES", // Puedes cambiar a "es_CO", "es_MX", etc.
        listenFor: Duration(seconds: 90), // Tiempo muy largo
        pauseFor: Duration(seconds: 6), // Pausa muy larga
        partialResults: true,
        cancelOnError: false, // No cancelar automáticamente
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation, // Mejor para dictado
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (e) {
      print('❌ Error al iniciar listening: $e');
      _showErrorSnackBar('Error al iniciar reconocimiento de voz');
      _handleSpeechEnd();
    }
  }

  /// Detener la escucha de voz - VERSIÓN CORREGIDA
  void _stopListening() async {
    print('🛑 Deteniendo reconocimiento de voz...');

    try {
      _speechTimer?.cancel();
      await _speechToText.stop();

      // Dar tiempo para procesar último resultado
      await Future.delayed(Duration(milliseconds: 300));

      _handleSpeechEnd();
    } catch (e) {
      print('❌ Error al detener listening: $e');
      _handleSpeechEnd();
    }
  }

  /// Callback cuando se recibe resultado de voz - VERSIÓN CORREGIDA
  void _onSpeechResult(result) {
    String resultText = result.recognizedWords ?? '';
    bool isFinal = result.finalResult ?? false;
    double confidence = result.confidence ?? 0.0;

    print('🎤 Resultado - Final: $isFinal, Confianza: $confidence, Texto: "$resultText"');

    if (resultText.isEmpty) return;

    setState(() {
      _lastWords = resultText;
      _finalRecognizedText = resultText; // Siempre guardar el último resultado

      if (_activeController != null) {
        // Mostrar resultado en tiempo real
        String displayText = _baseText.isEmpty ? resultText :
        (_baseText.endsWith(' ') ? _baseText + resultText : _baseText + ' ' + resultText);

        _activeController!.text = displayText;
        _activeController!.selection = TextSelection.fromPosition(
          TextPosition(offset: _activeController!.text.length),
        );

        // Si es resultado final, actualizar base text
        if (isFinal) {
          _baseText = displayText;
          print('✅ Resultado FINAL confirmado: "$displayText"');

          // Programar finalización con delay
          _speechTimer?.cancel();
          _speechTimer = Timer(Duration(milliseconds: 1000), () {
            if (!_isListening) return; // Si ya se detuvo, no hacer nada

            print('🏁 Finalizando por resultado final...');
            _handleSpeechEnd();
          });
        }
      }
    });
  }

  /// MÉTODO ALTERNATIVO: Reconocimiento continuo mejorado
  void _startContinuousListening(TextEditingController controller) async {
    PermissionStatus status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      _showErrorSnackBar('Permisos de micrófono denegados');
      return;
    }

    if (!_speechEnabled) {
      _showErrorSnackBar('Reconocimiento de voz no disponible');
      return;
    }

    _speechTimer?.cancel();
    _baseText = controller.text;
    _finalRecognizedText = '';

    setState(() {
      _activeController = controller;
      _isListening = true;
      _lastWords = '';
    });

    try {
      await _speechToText.listen(
        onResult: (result) {
          String text = result.recognizedWords ?? '';
          if (text.isEmpty) return;

          print('🔄 Continuo - Texto: "$text", Final: ${result.finalResult}');

          setState(() {
            _finalRecognizedText = text;

            if (_activeController != null) {
              String fullText = _baseText.isEmpty ? text :
              (_baseText.endsWith(' ') ? _baseText + text : _baseText + ' ' + text);

              _activeController!.text = fullText;
              _activeController!.selection = TextSelection.fromPosition(
                TextPosition(offset: _activeController!.text.length),
              );
            }
          });
        },
        localeId: "es_ES",
        listenFor: Duration(minutes: 5), // Muy largo
        pauseFor: Duration(seconds: 8), // Pausa muy larga
        partialResults: true,
        cancelOnError: false,
      );
    } catch (e) {
      print('❌ Error en reconocimiento continuo: $e');
      _handleSpeechEnd();
    }
  }

  /// MÉTODO ALTERNATIVO: Solo usar resultados finales (sin repetición)
  void _startListeningFinalOnly(TextEditingController controller) async {
    // Verificar permisos de micrófono
    PermissionStatus status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      _showErrorSnackBar('Permisos de micrófono denegados');
      return;
    }

    if (!_speechEnabled) {
      _showErrorSnackBar('Reconocimiento de voz no disponible');
      return;
    }

    _baseText = controller.text;

    setState(() {
      _activeController = controller;
      _isListening = true;
      _lastWords = '';
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResultFinalOnly,
        localeId: "es_ES",
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 2),
        partialResults: false, // ¡CLAVE! Solo resultados finales
        cancelOnError: true,
      );
    } catch (e) {
      print('Error al iniciar listening: $e');
      _showErrorSnackBar('Error al iniciar reconocimiento de voz');
      setState(() {
        _isListening = false;
        _activeController = null;
        _baseText = '';
      });
    }
  }

  /// Callback para resultados finales únicamente
  void _onSpeechResultFinalOnly(result) {
    // Solo procesar si es un resultado final
    if (result.finalResult && _activeController != null) {
      setState(() {
        _lastWords = result.recognizedWords;

        if (_lastWords.isNotEmpty) {
          if (_baseText.isEmpty) {
            _activeController!.text = _lastWords;
          } else {
            String separator = _baseText.endsWith(' ') ? '' : ' ';
            _activeController!.text = _baseText + separator + _lastWords;
          }

          // Actualizar el texto base para la siguiente escucha
          _baseText = _activeController!.text;

          // Mover cursor al final
          _activeController!.selection = TextSelection.fromPosition(
            TextPosition(offset: _activeController!.text.length),
          );
        }
      });
    }
  }

  /// Mostrar mensaje de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar mensaje de información
  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Formulario de Cultivo",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Completa la información básica de tu cultivo",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Indicador de estado de voz
                  if (_speechEnabled)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.red : Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _isListening ? "Escuchando..." : "Listo",
                            style: TextStyle(
                              color: _isListening ? Colors.red[700] : Colors.green[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 32),

              _buildSection("Información Básica", [
                _buildTextField(
                  controller: _nombreController,
                  label: "Nombre del cultivo",
                  hint: "Ej: Maíz lote norte",
                  icon: Icons.agriculture,
                  required: true,
                  showVoiceButton: true,
                ),
                SizedBox(height: 16),
                _buildDropdownField(
                  value: _tipoController.text.isEmpty ? null : _tipoController.text,
                  items: _tiposCultivo,
                  label: "Tipo de cultivo",
                  icon: Icons.category,
                  onChanged: (value) {
                    setState(() {
                      _tipoController.text = value ?? '';
                    });
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _variedadController,
                  label: "Variedad",
                  hint: "Ej: Criolla, Híbrida",
                  icon: Icons.grass,
                  showVoiceButton: true,
                ),
              ]),

              SizedBox(height: 24),

              _buildSection("Detalles del Cultivo", [
                // Usamos Column en lugar de Row para evitar overflow
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _areaController,
                            label: "Área (m²)",
                            hint: "Ej: 1000",
                            icon: Icons.straighten,
                            keyboardType: TextInputType.number,
                            required: true,
                            showVoiceButton: true,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            value: _estadoSeleccionado,
                            items: _estados,
                            label: "Estado actual",
                            icon: Icons.timeline,
                            onChanged: (value) {
                              setState(() {
                                _estadoSeleccionado = value ?? 'Siembra';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildDateField(),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _ubicacionController,
                      label: "Ubicación",
                      hint: "Ej: Lote 3, Sector norte",
                      icon: Icons.location_on,
                      showVoiceButton: true,
                    ),
                  ],
                ),
              ]),

              SizedBox(height: 24),

              _buildSection("Notas Adicionales", [
                _buildTextField(
                  controller: _notasController,
                  label: "Observaciones",
                  hint: "Notas sobre el cultivo, condiciones especiales, etc.",
                  icon: Icons.note,
                  maxLines: 4,
                  showVoiceButton: true,
                ),
              ]),

              SizedBox(height: 32),

              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool showVoiceButton = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: required ? (value) {
            if (value == null || value.isEmpty) {
              return 'Este campo es requerido';
            }
            return null;
          } : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Color(0xFF4CAF50)) : null,
            suffixIcon: showVoiceButton && _speechEnabled ?
            IconButton(
              icon: Icon(
                _isListening && _activeController == controller
                    ? Icons.mic
                    : Icons.mic_none,
                color: _isListening && _activeController == controller
                    ? Colors.red
                    : Color(0xFF4CAF50),
              ),
              onPressed: () {
                if (_isListening && _activeController == controller) {
                  _stopListening();
                } else {
                  // RECOMIENDA USAR EL MÉTODO HÍBRIDO PARA MEJORES RESULTADOS
                  //_startListening(controller);
                  // OPCIÓN 2: Método continuo (más agresivo)
                   _startContinuousListening(controller);
                  // Alternativas disponibles:
                  // _startListening(controller);  // Método original corregido
                  // _startListeningFinalOnly(controller);  // Solo resultados finales
                }
              },
            )
                : (showVoiceButton ? IconButton(
              icon: Icon(Icons.mic_off, color: Colors.grey[400]),
              onPressed: () {
                _showInfoSnackBar('Reconocimiento de voz no disponible');
              },
            ) : null),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    IconData? icon,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: Color(0xFF4CAF50)) : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fecha de siembra",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _fechaSiembra,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _fechaSiembra = date;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                SizedBox(width: 12),
                Text(
                  '${_fechaSiembra.day}/${_fechaSiembra.month}/${_fechaSiembra.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _formKey.currentState?.reset();
              _nombreController.clear();
              _tipoController.clear();
              _areaController.clear();
              _notasController.clear();
              _ubicacionController.clear();
              _variedadController.clear();
              setState(() {
                _fechaSiembra = DateTime.now();
                _estadoSeleccionado = 'Siembra';
              });
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Limpiar",
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _guardarCultivo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              "Guardar Cultivo",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _guardarCultivo() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      _showErrorSnackBar('Error: Usuario no identificado');
      return;
    }

    final cultivo = {
      'user_id': userId,
      'nombre': _nombreController.text,
      'tipo_cultivo': _tipoController.text.isEmpty ? 'Otro' : _tipoController.text,
      'variedad': _variedadController.text,
      'area': double.tryParse(_areaController.text) ?? 0.0,
      'estado': _estadoSeleccionado,
      'fecha_siembra': _fechaSiembra.toIso8601String(),
      'ubicacion': _ubicacionController.text,
      'notas': _notasController.text,
      'fecha_creacion': DateTime.now().toIso8601String(),
    };

    try {
      await DatabaseHelper.instance.insertarCultivo(cultivo);

      _showInfoSnackBar('Cultivo guardado exitosamente');
      widget.onGuardado();
    } catch (e) {
      _showErrorSnackBar('Error al guardar: $e');
    }
  }

  @override
  void dispose() {
    // Limpiar timer y recursos
    _speechTimer?.cancel();

    if (_isListening) {
      _speechToText.stop();
    }

    _baseText = '';
    _finalRecognizedText = '';
    _activeController = null;

    // Dispose de controllers...
    _nombreController.dispose();
    _tipoController.dispose();
    _areaController.dispose();
    _notasController.dispose();
    _ubicacionController.dispose();
    _variedadController.dispose();
    super.dispose();
  }
}

// VERSIÓN ACTUALIZADA DE DetalleCultivoScreen CON HISTORIAL DE NOTAS

class DetalleCultivoScreen extends StatefulWidget {
  final Map<String, dynamic> cultivo;

  const DetalleCultivoScreen({required this.cultivo});

  @override
  _DetalleCultivoScreenState createState() => _DetalleCultivoScreenState();
}

class _DetalleCultivoScreenState extends State<DetalleCultivoScreen> {
  bool _isEditing = false;
  late Map<String, dynamic> _cultivoData;
  List<Map<String, dynamic>> _historialNotas = [];

  // Controllers para edición (SIN controlador para notas)
  late TextEditingController _nombreController;
  late TextEditingController _ubicacionController;
  late TextEditingController _variedadController;

  // Nuevo controlador para agregar notas
  final TextEditingController _nuevaNotaController = TextEditingController();

  late String _estadoSeleccionado;

  final List<String> _estados = ['Siembra', 'Crecimiento', 'Floración', 'Cosecha'];

  @override
  void initState() {
    super.initState();
    _cultivoData = Map<String, dynamic>.from(widget.cultivo);
    _initializeControllers();
    _cargarHistorialNotas();
  }

  void _initializeControllers() {
    _nombreController = TextEditingController(text: _cultivoData['nombre'] ?? '');
    _ubicacionController = TextEditingController(text: _cultivoData['ubicacion'] ?? '');
    _variedadController = TextEditingController(text: _cultivoData['variedad'] ?? '');
    _estadoSeleccionado = _cultivoData['estado'] ?? 'Siembra';
  }

  Future<void> _cargarHistorialNotas() async {
    try {
      // Cargar historial de notas desde registros_cultivos
      final notas = await DatabaseHelper.instance.obtenerRegistrosPorTipo(
          _cultivoData['id'],
          'nota'
      );

      setState(() {
        _historialNotas = notas;
      });
    } catch (e) {
      print('Error cargando historial de notas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _cultivoData['nombre'] ?? 'Detalle Cultivo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _guardarCambios();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _initializeControllers(); // Restaurar valores originales
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con información principal
            _buildHeader(),

            // Contenido principal
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Información básica
                  _buildInfoCard(),
                  SizedBox(height: 20),

                  // Estadísticas y progreso
                  _buildStatsCard(),
                  SizedBox(height: 20),

                  // Detalles técnicos
                  _buildTechnicalCard(),
                  SizedBox(height: 20),

                  // Historial de notas y observaciones (NUEVA SECCIÓN)
                  _buildHistorialNotasCard(),
                  SizedBox(height: 20),

                  // Cronología
                  _buildTimelineCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !_isEditing ? FloatingActionButton.extended(
        onPressed: () {
          _showDeleteDialog();
        },
        backgroundColor: Colors.red,
        icon: Icon(Icons.delete, color: Colors.white),
        label: Text("Eliminar", style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF66BB6A),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCultivoIcon(_cultivoData['tipo_cultivo']),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cultivoData['tipo_cultivo'] ?? 'Cultivo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        _cultivoData['nombre'] ?? 'Sin nombre',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_cultivoData['estado']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    _cultivoData['estado'] ?? 'Sin estado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                "Información General",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Nombre
          _isEditing
              ? _buildEditableField("Nombre", _nombreController)
              : _buildInfoRow(Icons.agriculture, "Nombre", _cultivoData['nombre'] ?? 'No especificado'),

          SizedBox(height: 16),

          // Tipo y Variedad
          _buildInfoRow(Icons.category, "Tipo", _cultivoData['tipo_cultivo'] ?? 'No especificado'),
          SizedBox(height: 16),

          // Variedad
          _isEditing
              ? _buildEditableField("Variedad", _variedadController)
              : _buildInfoRow(Icons.grass, "Variedad", _cultivoData['variedad']?.isEmpty ?? true ? 'No especificada' : _cultivoData['variedad']),

          SizedBox(height: 16),

          // Estado
          _isEditing
              ? _buildEditableDropdown()
              : _buildInfoRow(Icons.timeline, "Estado", _cultivoData['estado'] ?? 'No especificado'),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                "Estadísticas",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  Icons.straighten,
                  "Área",
                  "${_cultivoData['area'] ?? 0} m²",
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  Icons.calendar_today,
                  "Días transcurridos",
                  _calculateDaysFromPlanting(),
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  Icons.trending_up,
                  "Progreso",
                  _calculateProgress(),
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  Icons.note,
                  "Notas registradas",
                  "${_historialNotas.length}",
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_outlined, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                "Detalles Técnicos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoRow(Icons.calendar_month, "Fecha de siembra", _formatDate(_cultivoData['fecha_siembra'])),
          SizedBox(height: 16),
          _isEditing
              ? _buildEditableField("Ubicación", _ubicacionController)
              : _buildInfoRow(Icons.location_on, "Ubicación", _cultivoData['ubicacion']?.isEmpty ?? true ? 'No especificada' : _cultivoData['ubicacion']),
          SizedBox(height: 16),
          _buildInfoRow(Icons.access_time, "Registrado el", _formatDate(_cultivoData['fecha_creacion'])),
        ],
      ),
    );
  }

  // NUEVA SECCIÓN: Historial de Notas
  Widget _buildHistorialNotasCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Historial de Notas y Observaciones",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Color(0xFF4CAF50)),
                onPressed: _mostrarDialogoNuevaNota,
              ),
            ],
          ),
          SizedBox(height: 20),

          // Mostrar nota inicial si existe
          if (_cultivoData['notas'] != null && _cultivoData['notas'].isNotEmpty) ...[
            _buildNotaItem(
              "Nota inicial",
              _cultivoData['notas'],
              _formatDate(_cultivoData['fecha_creacion']),
              true, // Es nota inicial
            ),
            if (_historialNotas.isNotEmpty) Divider(height: 32),
          ],

          // Mostrar historial de notas
          if (_historialNotas.isEmpty && (_cultivoData['notas']?.isEmpty ?? true))
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.note_add, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text(
                    "No hay observaciones registradas",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Agrega tu primera observación",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ...(_historialNotas.map((nota) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _buildNotaItem(
                "Observación",
                nota['descripcion'] ?? '',
                _formatDateTime(nota['fecha_registro']),
                false,
              ),
            )).toList()),
        ],
      ),
    );
  }

  Widget _buildNotaItem(String tipo, String contenido, String fecha, bool esInicial) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esInicial ? Color(0xFF4CAF50).withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: esInicial ? Border.all(color: Color(0xFF4CAF50).withOpacity(0.2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  esInicial ? Icons.note : Icons.add_comment,
                  size: 16,
                  color: esInicial ? Color(0xFF4CAF50) : Colors.grey[600]
              ),
              SizedBox(width: 8),
              Text(
                tipo,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: esInicial ? Color(0xFF4CAF50) : Colors.grey[600],
                ),
              ),
              Spacer(),
              Text(
                fecha,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            contenido,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                "Cronología del Cultivo",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildTimelineItem(
            Icons.play_arrow,
            "Cultivo registrado",
            _formatDate(_cultivoData['fecha_creacion']),
            true,
          ),
          _buildTimelineItem(
            Icons.grass,
            "Siembra realizada",
            _formatDate(_cultivoData['fecha_siembra']),
            true,
          ),
          _buildTimelineItem(
            Icons.trending_up,
            "Estado: ${_cultivoData['estado']}",
            "Actual",
            true,
          ),
          if (_historialNotas.isNotEmpty)
            _buildTimelineItem(
              Icons.note,
              "Última observación",
              _formatDate(_historialNotas.first['fecha_registro']),
              true,
            ),
          _buildTimelineItem(
            Icons.agriculture,
            "Próximo seguimiento",
            "Pendiente",
            false,
          ),
        ],
      ),
    );
  }

  // Métodos helper existentes...
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Estado",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _estadoSeleccionado,
          items: _estados.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _estadoSeleccionado = value ?? 'Siembra';
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(IconData icon, String title, String subtitle, bool completed) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: completed ? Color(0xFF4CAF50) : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: completed ? Colors.white : Colors.grey[600],
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: completed ? Colors.grey[800] : Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NUEVO: Diálogo para agregar nueva nota
  void _mostrarDialogoNuevaNota() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_comment, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text('Nueva Observación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nuevaNotaController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe tus observaciones sobre el cultivo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nuevaNotaController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nuevaNotaController.text.trim().isNotEmpty) {
                _agregarNuevaNota();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50)),
            child: Text('Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _agregarNuevaNota() async {
    try {
      final registro = {
        'cultivo_id': _cultivoData['id'],
        'user_id': _cultivoData['user_id'],
        'tipo_registro': 'nota',
        'descripcion': _nuevaNotaController.text.trim(),
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      await DatabaseHelper.instance.insertarRegistroCultivo(registro);
      _nuevaNotaController.clear();
      await _cargarHistorialNotas();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Observación agregada correctamente'),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar observación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Métodos de cálculo y utilidad
  String _calculateDaysFromPlanting() {
    try {
      final plantingDate = DateTime.parse(_cultivoData['fecha_siembra']);
      final difference = DateTime.now().difference(plantingDate).inDays;
      return "$difference días";
    } catch (e) {
      return "N/A";
    }
  }

  String _calculateProgress() {
    final estado = _cultivoData['estado'];
    switch (estado) {
      case 'Siembra': return "25%";
      case 'Crecimiento': return "50%";
      case 'Floración': return "75%";
      case 'Cosecha': return "100%";
      default: return "0%";
    }
  }

  Color _getStatusColor(String? estado) {
    switch (estado) {
      case 'Siembra': return Colors.orange;
      case 'Crecimiento': return Colors.blue;
      case 'Floración': return Colors.purple;
      case 'Cosecha': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCultivoIcon(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'maíz': return Icons.grain;
      case 'tomate': return Icons.local_florist;
      case 'papa': return Icons.circle;
      case 'café': return Icons.coffee;
      case 'arroz': return Icons.grass;
      default: return Icons.agriculture;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'No disponible';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'No disponible';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _guardarCambios() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El nombre del cultivo es obligatorio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF4CAF50)),
                SizedBox(height: 16),
                Text('Guardando cambios...'),
              ],
            ),
          ),
        ),
      );

      final updatedCultivo = {
        ..._cultivoData,
        'nombre': _nombreController.text.trim(),
        'ubicacion': _ubicacionController.text.trim(),
        'variedad': _variedadController.text.trim(),
        'estado': _estadoSeleccionado,
      };

      await DatabaseHelper.instance.actualizarCultivo(_cultivoData['id'], updatedCultivo);

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      setState(() {
        _cultivoData = updatedCultivo;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Cambios guardados exitosamente'),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Cerrar diálogo de carga si existe
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error al guardar cambios: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Cultivo'),
        content: Text('¿Estás seguro de que deseas eliminar este cultivo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _eliminarCultivo();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _eliminarCultivo() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.red),
                SizedBox(height: 16),
                Text('Eliminando cultivo...'),
              ],
            ),
          ),
        ),
      );

      await DatabaseHelper.instance.eliminarCultivo(_cultivoData['id']);

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      // Retornar a la pantalla anterior indicando que se eliminó
      Navigator.of(context).pop(true);

    } catch (e) {
      // Cerrar diálogo de carga si existe
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error al eliminar cultivo: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ubicacionController.dispose();
    _variedadController.dispose();
    _nuevaNotaController.dispose();
    super.dispose();
  }
}