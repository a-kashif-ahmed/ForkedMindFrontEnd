import '../pieces/chess_piece.dart';
import 'move_generator.dart';

/// Check if a king of given color is in check
bool isKingInCheck(List<ChessPiece?> board, PieceColor kingColor) {
  // Find the king's position
  int? kingIndex;
  for (int i = 0; i < 64; i++) {
    final piece = board[i];
    if (piece != null && piece.type == PieceType.king && piece.color == kingColor) {
      kingIndex = i;
      break;
    }
  }

  if (kingIndex == null) return false; // No king found (shouldn't happen)

  // Check if any opponent piece can attack the king's position
  final opponentColor = kingColor == PieceColor.white 
      ? PieceColor.black 
      : PieceColor.white;

  for (int i = 0; i < 64; i++) {
    final piece = board[i];
    if (piece != null && piece.color == opponentColor) {
      final moves = _getMovesForPiece(i, board);
      if (moves.contains(kingIndex)) {
        return true; // King is under attack
      }
    }
  }

  return false;
}

/// Check if a move would leave/put own king in check
bool wouldBeInCheck(
  List<ChessPiece?> board,
  int fromIndex,
  int toIndex,
  PieceColor playerColor,
) {
  // Create a temporary board with the move applied
  final tempBoard = List<ChessPiece?>.from(board);
  tempBoard[toIndex] = tempBoard[fromIndex];
  tempBoard[fromIndex] = null;

  // Check if king is in check after this move
  return isKingInCheck(tempBoard, playerColor);
}

/// Get all legal moves (excluding moves that would put own king in check)
List<int> getLegalMoves(int fromIndex, List<ChessPiece?> board) {
  final piece = board[fromIndex];
  if (piece == null) return [];

  final pseudoLegalMoves = _getMovesForPiece(fromIndex, board);
  final legalMoves = <int>[];

  // Filter out moves that would leave king in check
  for (final toIndex in pseudoLegalMoves) {
    if (!wouldBeInCheck(board, fromIndex, toIndex, piece.color)) {
      legalMoves.add(toIndex);
    }
  }

  return legalMoves;
}

/// Check if the current player is in checkmate
bool isCheckmate(List<ChessPiece?> board, PieceColor playerColor) {
  // Must be in check to be in checkmate
  if (!isKingInCheck(board, playerColor)) {
    return false;
  }

  // Check if any piece has a legal move that gets out of check
  for (int i = 0; i < 64; i++) {
    final piece = board[i];
    if (piece != null && piece.color == playerColor) {
      final legalMoves = getLegalMoves(i, board);
      if (legalMoves.isNotEmpty) {
        return false; // Found a legal move, not checkmate
      }
    }
  }

  return true; // No legal moves available, checkmate!
}

/// Check if the current player is in stalemate (not in check but no legal moves)
bool isStalemate(List<ChessPiece?> board, PieceColor playerColor) {
  // Must NOT be in check for stalemate
  if (isKingInCheck(board, playerColor)) {
    return false;
  }

  // Check if any piece has a legal move
  for (int i = 0; i < 64; i++) {
    final piece = board[i];
    if (piece != null && piece.color == playerColor) {
      final legalMoves = getLegalMoves(i, board);
      if (legalMoves.isNotEmpty) {
        return false; // Found a legal move, not stalemate
      }
    }
  }

  return true; // No legal moves but not in check = stalemate
}

/// Helper function to get moves for any piece type
List<int> _getMovesForPiece(int index, List<ChessPiece?> board) {
  final piece = board[index];
  if (piece == null) return [];

  switch (piece.type) {
    case PieceType.pawn:
      return generatePawnMoves(index, board);
    case PieceType.knight:
      return generateKnightMoves(index, board);
    case PieceType.bishop:
      return generateBishopMoves(index, board);
    case PieceType.rook:
      return generateRookMoves(index, board);
    case PieceType.queen:
      return generateQueenMoves(index, board);
    case PieceType.king:
      return generateKingMoves(index, board);
  }
}

/// Game state enum
enum GameState {
  ongoing,
  check,
  checkmate,
  stalemate,
  draw,
}

/// Get current game state
GameState getGameState(List<ChessPiece?> board, PieceColor currentPlayer) {
  if (isCheckmate(board, currentPlayer)) {
    return GameState.checkmate;
  }
  
  if (isStalemate(board, currentPlayer)) {
    return GameState.stalemate;
  }
  
  if (isKingInCheck(board, currentPlayer)) {
    return GameState.check;
  }
  
  return GameState.ongoing;
}