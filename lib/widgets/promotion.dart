import 'package:flutter/material.dart';
import 'chess_piece_widget.dart';
import '../pieces/chess_piece.dart';

/// Shows a dialog for pawn promotion
/// Returns the selected PieceType (queen, rook, bishop, or knight)
Future<PieceType?> showPromotionDialog(
  BuildContext context,
  PieceColor color,
) async {
  return showDialog<PieceType>(
    context: context,
    barrierDismissible: false, // Must choose a piece
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Promote Pawn',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose a piece:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PromotionOption(
                  piece: ChessPiece(type: PieceType.queen, color: color),
                  onTap: () => Navigator.of(context).pop(PieceType.queen),
                ),
                _PromotionOption(
                  piece: ChessPiece(type: PieceType.rook, color: color),
                  onTap: () => Navigator.of(context).pop(PieceType.rook),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PromotionOption(
                  piece: ChessPiece(type: PieceType.bishop, color: color),
                  onTap: () => Navigator.of(context).pop(PieceType.bishop),
                ),
                _PromotionOption(
                  piece: ChessPiece(type: PieceType.knight, color: color),
                  onTap: () => Navigator.of(context).pop(PieceType.knight),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// Widget for a single promotion option
class _PromotionOption extends StatelessWidget {
  final ChessPiece piece;
  final VoidCallback onTap;

  const _PromotionOption({
    required this.piece,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: ChessPieceWidget(
          piece: piece,
          squareSize: 80,
        ),
      ),
    );
  }
}