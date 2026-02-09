import 'package:flutter/material.dart';

import '../pieces/chess_piece.dart';

class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double squareSize;

  const ChessPieceWidget({super.key, required this.piece,required this.squareSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        _assetPath,
        width: squareSize *0.7,
        height: squareSize *0.7,
      ),
    );
  }

  String get _assetPath {
    final color = piece.color == PieceColor.white ? 'white' : 'black';

    switch (piece.type) {
      case PieceType.king:
        return 'assets/pieces/${color}_king.png';
      case PieceType.queen:
        return 'assets/pieces/${color}_queen.png';
      case PieceType.rook:
        return 'assets/pieces/${color}_rook.png';
      case PieceType.bishop:
        return 'assets/pieces/${color}_bishop.png';
      case PieceType.knight:
        return 'assets/pieces/${color}_knight.png';
      case PieceType.pawn:
        return 'assets/pieces/${color}_pawn.png';
    }
  }
}
