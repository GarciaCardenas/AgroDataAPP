import 'package:flutter/material.dart';
import 'custom_drawer.dart';

class DetectarEnfermedadScreen extends StatefulWidget {
  const DetectarEnfermedadScreen({super.key});

  @override
  State<DetectarEnfermedadScreen> createState() => _DetectarEnfermedadScreenState();
}

class _DetectarEnfermedadScreenState extends State<DetectarEnfermedadScreen> {
  String searchQuery = '';

  final cultivos = [
    {'nombre': 'Papa', 'imagen': 'assets/images/papa.jpg', 'categoria': 'Tubérculo', 'icon': Icons.eco},
    {'nombre': 'Maíz', 'imagen': 'assets/images/maiz.jpg', 'categoria': 'Cereal', 'icon': Icons.grass},
    {'nombre': 'Café', 'imagen': 'assets/images/cafe.jpg', 'categoria': 'Arbusto', 'icon': Icons.local_cafe},
    {'nombre': 'Cebolla', 'imagen': 'assets/images/cebolla.jpg', 'categoria': 'Bulbo', 'icon': Icons.circle},
    {'nombre': 'Tomate', 'imagen': 'assets/images/tomate.jpg', 'categoria': 'Fruto', 'icon': Icons.circle_outlined},
    {'nombre': 'Aguacate', 'imagen': 'assets/images/aguacate.jpg', 'categoria': 'Árbol', 'icon': Icons.park},
    {'nombre': 'Plátano', 'imagen': 'assets/images/platano.jpg', 'categoria': 'Fruto', 'icon': Icons.nature},
    {'nombre': 'Soya', 'imagen': 'assets/images/soya.jpg', 'categoria': 'Leguminosa', 'icon': Icons.scatter_plot},
    {'nombre': 'Arroz', 'imagen': 'assets/images/arroz.jpg', 'categoria': 'Cereal', 'icon': Icons.grass},
    {'nombre': 'Trigo', 'imagen': 'assets/images/trigo.jpg', 'categoria': 'Cereal', 'icon': Icons.agriculture},
    {'nombre': 'Uva', 'imagen': 'assets/images/uva.jpg', 'categoria': 'Fruto', 'icon': Icons.bubble_chart},
    {'nombre': 'Otro cultivo', 'imagen': 'assets/images/otro_cultivo.jpg', 'categoria': 'General', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    final cultivosFiltrados = cultivos.where((cultivo) {
      return (cultivo['nombre'] as String).toLowerCase().contains(searchQuery.toLowerCase()) ||
          (cultivo['categoria'] as String).toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      drawer: CustomDrawer(context),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Diagnóstico IA",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2196F3),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con gradiente
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2196F3),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detección Inteligente",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Identifica enfermedades con precisión del 98%",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Estadísticas rápidas
            Container(
              margin: EdgeInsets.all(24),
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.biotech,
                          color: Color(0xFF2196F3),
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "200+",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          "Enfermedades",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 50, color: Colors.grey[200]),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: Color(0xFFFF9800),
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "< 2s",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          "Resultado",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 50, color: Colors.grey[200]),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.verified,
                          color: Color(0xFF4CAF50),
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "98.5%",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          "Precisión",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Título y búsqueda
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selecciona tu Cultivo",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Elige el tipo de cultivo para un análisis más preciso",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Barra de búsqueda
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Buscar cultivo...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Grid de cultivos
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: cultivosFiltrados.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final cultivo = cultivosFiltrados[index];
                  return _buildCultivoCard(context, cultivo);
                },
              ),
            ),

            SizedBox(height: 32),

            // Sección de ayuda mejorada
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF50).withOpacity(0.1),
                    Color(0xFF2196F3).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_center,
                    size: 48,
                    color: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "¿Necesitas Ayuda?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Conecta con expertos y otros agricultores",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/comunidad'),
                    icon: Icon(Icons.people, size: 20),
                    label: Text("Ir a la Comunidad"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Instrucciones rápidas
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
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
                    "Consejos para mejores resultados:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildTipItem(Icons.wb_sunny, "Toma fotos con buena iluminación"),
                  _buildTipItem(Icons.center_focus_strong, "Enfoca la parte afectada"),
                  _buildTipItem(Icons.straighten, "Mantén la cámara estable"),
                ],
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCultivoCard(BuildContext context, Map<String, dynamic> cultivo) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/photo',
          arguments: {
            'cropType': cultivo['nombre']!.toLowerCase(),
            'mode': 'photo',
          },
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      child: Image.asset(
                        cultivo['imagen']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Tag de categoría
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cultivo['categoria']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cultivo['nombre']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                cultivo['icon'] as IconData,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  cultivo['categoria']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Color(0xFF4CAF50),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}