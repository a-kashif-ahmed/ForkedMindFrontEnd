import 'package:flutter/material.dart';

class ChessSquare extends StatelessWidget {
  final bool isDark;
  final bool selected;
  final bool highlight;

  const ChessSquare({
    super.key,
    required this.isDark,
    this.selected=false,
    this.highlight= false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: selected
            ? Border.all(color: Colors.yellow, width: 3)
            : null,
      ),
      child: highlight
          ? Center(
              child: Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 21, 255).withOpacity(0.4),
                  shape: BoxShape.rectangle,
                ),
              ),
            )
          : null,
    );
  }
}
