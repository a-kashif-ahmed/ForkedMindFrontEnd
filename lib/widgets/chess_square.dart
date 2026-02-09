import 'package:flutter/material.dart';
import '../constants/colors.dart';

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
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
