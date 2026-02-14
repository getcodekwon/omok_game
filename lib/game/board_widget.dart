
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_provider.dart';
import 'omok_logic.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color(0xFFDCB35C), // Classic wood color
        child: LayoutBuilder(
          builder: (context, constraints) {
                final double gridSize = constraints.maxWidth / 15;
                final double dx = details.localPosition.dx;
                final double dy = details.localPosition.dy;

                int col = (dx / gridSize).floor();
                int row = (dy / gridSize).floor();

                if (row >= 0 && row < 15 && col >= 0 && col < 15) {
                  context.read<GameProvider>().placeStone(row, col);
                }
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: BoardPainter(context.watch<GameProvider>().board),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final List<List<Player>> board;

  BoardPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    final double gridSize = size.width / 15;
    final Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Draw grid
    for (int i = 0; i < 15; i++) {
      double offset = gridSize * i + gridSize / 2;
      // Vertical lines
      canvas.drawLine(
        Offset(offset, gridSize / 2),
        Offset(offset, size.height - gridSize / 2),
        linePaint,
      );
      // Horizontal lines
      canvas.drawLine(
        Offset(gridSize / 2, offset),
        Offset(size.width - gridSize / 2, offset),
        linePaint,
      );
    }

    // Draw stones
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (board[i][j] != Player.none) {
          final double x = j * gridSize + gridSize / 2;
          final double y = i * gridSize + gridSize / 2;
          final Paint stonePaint = Paint()
            ..color = board[i][j] == Player.black ? Colors.black : Colors.white;

          canvas.drawCircle(Offset(x, y), gridSize / 2 * 0.8, stonePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return true; // Simple approach: always repaint/check diff
  }
}
