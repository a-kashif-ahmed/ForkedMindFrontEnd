import '../pieces/chess_piece.dart';

/// Converts the current board state to FEN (Forsyth-Edwards Notation)
/// 
/// FEN format: [piece placement] [active color] [castling] [en passant] [halfmove] [fullmove]
/// Example: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
String boardToFEN(
  List<ChessPiece?> board,
  PieceColor currentTurn, {
  String castlingRights = 'KQkq', // Default: all castling available
  String enPassantTarget = '-',    // Default: no en passant
  int halfmoveClock = 0,           // Moves since last capture/pawn move
  int fullmoveNumber = 1,          // Increments after Black's move
}) {
  // 1. PIECE PLACEMENT (from rank 8 to rank 1)
  List<String> ranks = [];
  
  for (int row = 0; row < 8; row++) {
    String rank = '';
    int emptyCount = 0;
    
    for (int col = 0; col < 8; col++) {
      final index = row * 8 + col;
      final piece = board[index];
      
      if (piece == null) {
        emptyCount++;
      } else {
        // Add accumulated empty squares
        if (emptyCount > 0) {
          rank += emptyCount.toString();
          emptyCount = 0;
        }
        
        // Add piece symbol
        rank += _pieceToFEN(piece);
      }
    }
    
    // Add trailing empty squares
    if (emptyCount > 0) {
      rank += emptyCount.toString();
    }
    
    ranks.add(rank);
  }
  
  final piecePlacement = ranks.join('/');
  
  // 2. ACTIVE COLOR
  final activeColor = currentTurn == PieceColor.white ? 'w' : 'b';
  
  // 3. CASTLING AVAILABILITY
  // (would need to track if king/rooks have moved)
  
  // 4. EN PASSANT TARGET SQUARE
  // (would need to track last pawn double-move)
  
  // 5. HALFMOVE CLOCK
  // (would need to track captures and pawn moves)
  
  // 6. FULLMOVE NUMBER
  // (increments after each Black move)
  
  return '$piecePlacement $activeColor $castlingRights $enPassantTarget $halfmoveClock $fullmoveNumber';
}

/// Converts a ChessPiece to its FEN character
/// White pieces: uppercase (K, Q, R, B, N, P)
/// Black pieces: lowercase (k, q, r, b, n, p)
String _pieceToFEN(ChessPiece piece) {
  String symbol;
  
  switch (piece.type) {
    case PieceType.king:
      symbol = 'K';
      break;
    case PieceType.queen:
      symbol = 'Q';
      break;
    case PieceType.rook:
      symbol = 'R';
      break;
    case PieceType.bishop:
      symbol = 'B';
      break;
    case PieceType.knight:
      symbol = 'N';
      break;
    case PieceType.pawn:
      symbol = 'P';
      break;
  }
  
  // Lowercase for black pieces
  return piece.color == PieceColor.black ? symbol.toLowerCase() : symbol;
}

/// Parse FEN string back to board state (inverse operation)
/// Returns a tuple of (board, currentTurn)
(List<ChessPiece?>, PieceColor) fenToBoard(String fen) {
  final parts = fen.split(' ');
  final piecePlacement = parts[0];
  final activeColor = parts.length > 1 ? parts[1] : 'w';
  
  List<ChessPiece?> board = List.filled(64, null);
  final ranks = piecePlacement.split('/');
  
  for (int row = 0; row < 8 && row < ranks.length; row++) {
    int col = 0;
    
    for (final char in ranks[row].split('')) {
      if (char.contains(RegExp(r'[1-8]'))) {
        // Empty squares
        col += int.parse(char);
      } else {
        // Piece
        final index = row * 8 + col;
        board[index] = _fenToPiece(char);
        col++;
      }
    }
  }
  
  final turn = activeColor == 'w' ? PieceColor.white : PieceColor.black;
  
  return (board, turn);
}

/// Converts FEN character to ChessPiece
ChessPiece? _fenToPiece(String char) {
  final isWhite = char == char.toUpperCase();
  final color = isWhite ? PieceColor.white : PieceColor.black;
  
  PieceType? type;
  switch (char.toUpperCase()) {
    case 'K':
      type = PieceType.king;
      break;
    case 'Q':
      type = PieceType.queen;
      break;
    case 'R':
      type = PieceType.rook;
      break;
    case 'B':
      type = PieceType.bishop;
      break;
    case 'N':
      type = PieceType.knight;
      break;
    case 'P':
      type = PieceType.pawn;
      break;
  }
  
  return type != null ? ChessPiece(type: type, color: color) : null;
}