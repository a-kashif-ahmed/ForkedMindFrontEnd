import '../pieces/chess_piece.dart';

// PAWN MOVES
List<int> generatePawnMoves(
  int from,
  List<ChessPiece?> board,
) {
  final moves = <int>[];
  final row = from ~/ 8;
  final col = from % 8;
  final piece = board[from]!;
  final isWhite = piece.color == PieceColor.white;
  final direction = isWhite ? -1 : 1; // white moves up (-1), black moves down (+1)
  final startRow = isWhite ? 6 : 1;

  // Forward move (1 square)
  final oneSquare = from + (direction * 8);
  if (oneSquare >= 0 && oneSquare < 64 && board[oneSquare] == null) {
    moves.add(oneSquare);

    // Forward move (2 squares from starting position)
    if (row == startRow) {
      final twoSquares = from + (direction * 16);
      if (board[twoSquares] == null) {
        moves.add(twoSquares);
      }
    }
  }

  // Diagonal captures
  final captureOffsets = [direction * 8 - 1, direction * 8 + 1];
  for (final offset in captureOffsets) {
    final targetIndex = from + offset;
    if (targetIndex >= 0 && targetIndex < 64) {
      final targetRow = targetIndex ~/ 8;
      final targetCol = targetIndex % 8;
      
      // Ensure we're only moving 1 column (prevent wrapping)
      if ((targetCol - col).abs() == 1 && (targetRow - row).abs() == 1) {
        final target = board[targetIndex];
        if (target != null && target.color != piece.color) {
          moves.add(targetIndex);
        }
        // Note: En passant would require additional game state tracking
      }
    }
  }

  return moves;
}

// KNIGHT MOVES
List<int> generateKnightMoves(
  int from,
  List<ChessPiece?> board,
) {
  final moves = <int>[];
  final row = from ~/ 8;
  final col = from % 8;
  final piece = board[from]!;

  const knightMoves = [
    [-2, -1], [-2, 1], [-1, -2], [-1, 2],
    [1, -2], [1, 2], [2, -1], [2, 1],
  ];

  for (final move in knightMoves) {
    final newRow = row + move[0];
    final newCol = col + move[1];

    if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
      final index = newRow * 8 + newCol;
      final target = board[index];
      
      if (target == null || target.color != piece.color) {
        moves.add(index);
      }
    }
  }

  return moves;
}

// BISHOP MOVES
List<int> generateBishopMoves(
  int from,
  List<ChessPiece?> board,
) {
  final moves = <int>[];
  final row = from ~/ 8;
  final col = from % 8;
  final piece = board[from]!;

  const directions = [
    [-1, -1], [-1, 1], [1, -1], [1, 1], // all diagonals
  ];

  for (final d in directions) {
    int r = row + d[0];
    int c = col + d[1];

    while (r >= 0 && r < 8 && c >= 0 && c < 8) {
      final index = r * 8 + c;
      final target = board[index];

      if (target == null) {
        moves.add(index);
      } else {
        if (target.color != piece.color) {
          moves.add(index); // capture
        }
        break; // blocked by piece
      }

      r += d[0];
      c += d[1];
    }
  }

  return moves;
}

// ROOK MOVES
List<int> generateRookMoves(
  int from,
  List<ChessPiece?> board,
) {
  final moves = <int>[];
  final row = from ~/ 8;
  final col = from % 8;
  final piece = board[from]!;

  const directions = [
    [-1, 0], [1, 0], [0, -1], [0, 1], // up, down, left, right
  ];

  for (final d in directions) {
    int r = row + d[0];
    int c = col + d[1];

    while (r >= 0 && r < 8 && c >= 0 && c < 8) {
      final index = r * 8 + c;
      final target = board[index];

      if (target == null) {
        moves.add(index);
      } else {
        if (target.color != piece.color) {
          moves.add(index); // capture
        }
        break; // blocked by piece
      }

      r += d[0];
      c += d[1];
    }
  }

  return moves;
}

// QUEEN MOVES
List<int> generateQueenMoves(
  int from,
  List<ChessPiece?> board,
) {
  final moves = <int>[];
  final row = from ~/ 8;
  final col = from % 8;
  final piece = board[from]!;

  const directions = [
    [-1, 0], [1, 0], [0, -1], [0, 1], // rook moves
    [-1, -1], [-1, 1], [1, -1], [1, 1], // bishop moves
  ];

  for (final d in directions) {
    int r = row + d[0];
    int c = col + d[1];

    while (r >= 0 && r < 8 && c >= 0 && c < 8) {
      final index = r * 8 + c;
      final target = board[index];

      if (target == null) {
        moves.add(index);
      } else {
        if (target.color != piece.color) {
          moves.add(index); // capture
        }
        break; // blocked by piece
      }

      r += d[0];
      c += d[1];
    }
  }

  return moves;
}

// KING MOVES
List<int> generateKingMoves(
  int from,
  List<ChessPiece?> board,
) {
  final moves = <int>[];
  final row = from ~/ 8;
  final col = from % 8;
  final piece = board[from]!;

  const directions = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1],           [0, 1],
    [1, -1],  [1, 0],  [1, 1],
  ];

  for (final d in directions) {
    final newRow = row + d[0];
    final newCol = col + d[1];

    if (newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8) {
      final index = newRow * 8 + newCol;
      final target = board[index];

      if (target == null || target.color != piece.color) {
        moves.add(index);
      }
    }
  }

  // Note: Castling would require additional game state tracking
  // (king hasn't moved, rook hasn't moved, no pieces between, not in check)

  return moves;
}

/* 
CHESS PIECE MOVEMENT RULES SUMMARY:

1. PAWN:
   - Moves forward 1 square (cannot capture)
   - Moves forward 2 squares from starting position (if path is clear)
   - Captures diagonally forward 1 square
   - En passant: Special pawn capture (requires game state)
   - Promotion: Becomes another piece upon reaching the opposite end

2. KNIGHT:
   - Moves in an "L" shape: 2 squares in one direction, 1 square perpendicular
   - Can jump over other pieces
   - 8 possible moves maximum

3. BISHOP:
   - Moves diagonally any number of squares
   - Cannot jump over pieces
   - Always stays on the same color square

4. ROOK:
   - Moves horizontally or vertically any number of squares
   - Cannot jump over pieces
   - Used in castling with the king

5. QUEEN:
   - Combines rook and bishop moves
   - Moves horizontally, vertically, or diagonally any number of squares
   - Cannot jump over pieces
   - Most powerful piece

6. KING:
   - Moves 1 square in any direction (horizontal, vertical, or diagonal)
   - Cannot move into check
   - Castling: Special move with rook (requires game state)
   - Most important piece (game ends if checkmated)

SPECIAL MOVES NOT FULLY IMPLEMENTED:
- En passant (pawn): Requires tracking if opponent's pawn just moved 2 squares
- Castling (king + rook): Requires tracking piece movement history and checking for threats
- Pawn promotion: Requires UI for piece selection when pawn reaches end row
- Check/Checkmate detection: Requires validating king safety
*/