import 'package:flutter/material.dart';

class BoxOverlay extends StatelessWidget {
  const BoxOverlay({
    required this.boxes,
    required this.scores,
    required this.imgW,
    required this.imgH,
  });

  final List<List<double>> boxes;
  final List<double> scores;
  final int imgW, imgH;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final scaleX = constraints.maxWidth  / imgW;
        final scaleY = constraints.maxHeight / imgH;

        return Stack(
          children: [
            for (var i = 0; i < boxes.length; i++)
              Positioned(
                left:  boxes[i][0] * scaleX,
                top:   boxes[i][1] * scaleY,
                width: (boxes[i][2] - boxes[i][0]) * scaleX,
                height:(boxes[i][3] - boxes[i][1]) * scaleY,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      child: Text(
                        '${(scores[i] * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
