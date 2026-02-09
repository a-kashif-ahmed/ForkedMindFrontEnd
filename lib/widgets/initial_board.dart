import '../pieces/chess_piece.dart';

final List<ChessPiece?> initialBoard = _createInitialBoard();

List<ChessPiece?> _createInitialBoard() {
  final board = List<ChessPiece?>.filled(64, null);

  // Black pieces
  board[0] = const ChessPiece(type: PieceType.rook, color: PieceColor.black);
  board[1] = const ChessPiece(type: PieceType.knight, color: PieceColor.black);
  board[2] = const ChessPiece(type: PieceType.bishop, color: PieceColor.black);
  board[3] = const ChessPiece(type: PieceType.queen, color: PieceColor.black);
  board[4] = const ChessPiece(type: PieceType.king, color: PieceColor.black);
  board[5] = const ChessPiece(type: PieceType.bishop, color: PieceColor.black);
  board[6] = const ChessPiece(type: PieceType.knight, color: PieceColor.black);
  board[7] = const ChessPiece(type: PieceType.rook, color: PieceColor.black);

  for (int i = 8; i < 16; i++) {
    board[i] =
        const ChessPiece(type: PieceType.pawn, color: PieceColor.black);
  }

  // White pieces
  for (int i = 48; i < 56; i++) {
    board[i] =
        const ChessPiece(type: PieceType.pawn, color: PieceColor.white);
  }

  board[56] = const ChessPiece(type: PieceType.rook, color: PieceColor.white);
  board[57] = const ChessPiece(type: PieceType.knight, color: PieceColor.white);
  board[58] = const ChessPiece(type: PieceType.bishop, color: PieceColor.white);
  board[59] = const ChessPiece(type: PieceType.queen, color: PieceColor.white);
  board[60] = const ChessPiece(type: PieceType.king, color: PieceColor.white);
  board[61] = const ChessPiece(type: PieceType.bishop, color: PieceColor.white);
  board[62] = const ChessPiece(type: PieceType.knight, color: PieceColor.white);
  board[63] = const ChessPiece(type: PieceType.rook, color: PieceColor.white);

  return board;
}
