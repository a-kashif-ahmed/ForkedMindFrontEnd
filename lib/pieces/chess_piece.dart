enum PieceType { king, queen, rook, bishop, knight, pawn }
enum PieceColor { white, black }

class ChessPiece {
  final PieceType type;
  final PieceColor color;

  const ChessPiece({
    required this.type,
    required this.color,
  });
}
