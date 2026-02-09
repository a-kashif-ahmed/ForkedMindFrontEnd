import 'package:chess_app/pieces/chess_piece.dart';
import 'package:flutter/material.dart';
import 'chess_square.dart';
import 'initial_board.dart';
import 'chess_piece_widget.dart';
import '../logic/move_generator.dart';// Import the move generation functions
import '../logic/fen_converter.dart'; // Import FEN converter
import '../logic/checkmate.dart'; // Import checkmate detection
import '../widgets/promotion.dart';
import 'package:chess_app/fetch_fen.dart'; // Import FEN API service

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  List<ChessPiece?> board = List.from(initialBoard);
  int? selectedIndex;
  List<int> validMoves = [];
  PieceColor currentTurn = PieceColor.white;
  String currentFEN = '';
  int moveNumber = 1;
  List<String> fenHistory = [];
  GameState gameState = GameState.ongoing;
  List<ChessPiece> capturedPieces = [];

  @override
  void initState() {
    super.initState();
    currentFEN = boardToFEN(board, currentTurn, fullmoveNumber: moveNumber);
    fenHistory.add(currentFEN);
    print('Initial FEN: $currentFEN');
  }

  List<int> getValidMoves(int index) {
    final piece = board[index];
    if (piece == null) return [];
    return getLegalMoves(index, board);
  }

  void onSquareTap(int index) async {
    if (gameState == GameState.checkmate || gameState == GameState.stalemate) {
      _showGameOverDialog();
      return;
    }

    setState(() {
      final piece = board[index];

      if (selectedIndex == null) {
        if (piece != null && piece.color == currentTurn) {
          selectedIndex = index;
          validMoves = getValidMoves(index);
        }
      } 
      else {
        if (selectedIndex == index) {
          selectedIndex = null;
          validMoves = [];
        }
        else if (validMoves.contains(index)) {
          _makeMove(selectedIndex!, index);
        }
        else if (piece != null && piece.color == currentTurn) {
          selectedIndex = index;
          validMoves = getValidMoves(index);
        }
        else {
          selectedIndex = null;
          validMoves = [];
        }
      }
    });
  }

  void _makeMove(int from, int to) async {
    final movingPiece = board[from]!;
    final capturedPiece = board[to];

    if (capturedPiece != null) {
      capturedPieces.add(capturedPiece);
    }

    board[to] = board[from];
    board[from] = null;

    if (movingPiece.type == PieceType.pawn) {
      final row = to ~/ 8;
      if ((movingPiece.color == PieceColor.white && row == 0) ||
          (movingPiece.color == PieceColor.black && row == 7)) {
        final promotionType = await showPromotionDialog(context, movingPiece.color);
        if (promotionType != null) {
          board[to] = ChessPiece(type: promotionType, color: movingPiece.color);
        } else {
          board[to] = ChessPiece(type: PieceType.queen, color: movingPiece.color);
        }
      }
    }

    currentTurn = currentTurn == PieceColor.white 
        ? PieceColor.black 
        : PieceColor.white;

    if (currentTurn == PieceColor.white) {
      moveNumber++;
    }

    gameState = getGameState(board, currentTurn);

    currentFEN = boardToFEN(board, currentTurn, fullmoveNumber: moveNumber);
    fenHistory.add(currentFEN);

    print('Move ${fenHistory.length - 1}: $currentFEN');
    print('Game State: ${gameState.name}');

    selectedIndex = null;
    validMoves = [];

    if (gameState == GameState.checkmate || gameState == GameState.stalemate) {
      Future.delayed(Duration(milliseconds: 500), () {
        _showGameOverDialog();
      });
    }

    setState(() {});
  }

  void _showGameOverDialog() {
    String title = '';
    String message = '';

    switch (gameState) {
      case GameState.checkmate:
        final winner = currentTurn == PieceColor.white ? 'Black' : 'White';
        title = 'Checkmate!';
        message = '$winner wins!';
        break;
      case GameState.stalemate:
        title = 'Stalemate!';
        message = 'The game is a draw.';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Final FEN:',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            SelectableText(
              currentFEN,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('New Game'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    setState(() {
      board = List.from(initialBoard);
      selectedIndex = null;
      validMoves = [];
      currentTurn = PieceColor.white;
      moveNumber = 1;
      gameState = GameState.ongoing;
      capturedPieces.clear();
      currentFEN = boardToFEN(board, currentTurn, fullmoveNumber: moveNumber);
      fenHistory = [currentFEN];
    });
  }

  /// Load board state from FEN string
  void loadBoardFromFen(String fen) {
    try {
      final result = fenToBoard(fen);
      setState(() {
        board = result.$1;
        currentTurn = result.$2;
        selectedIndex = null;
        validMoves = [];
        gameState = getGameState(board, currentTurn);
        currentFEN = fen;
        
        // Recalculate captured pieces by comparing with initial board
        capturedPieces.clear();
        // Note: This is a simplified approach. For accurate tracking,
        // you'd need to store captured pieces in the FEN or track them separately
      });
      print('Board loaded from FEN: $fen');
    } catch (e) {
      print('Error loading FEN: $e');
    }
  }

  /// Fetch FEN from API and update board
  Future<void> fetchAndLoadFen(String apiUrl) async {
    try {
      final fen = await FenApiService.fetchFen(apiUrl);
      if (fen != null) {
        loadBoardFromFen(fen);
      } else {
        print('Failed to fetch FEN from API');
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch board position')),
          );
        }
      }
    } catch (e) {
      print('Error in fetchAndLoadFen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const labelSize = 16.0;
        final width = constraints.maxWidth;
        final isDesktop = width >= 900;
        final isSmall = width <= 320;

        double boardSize;

        if (isDesktop) {
          boardSize = 500;
        } else if (isSmall) {
          boardSize = width * 0.55;
        } else {
          boardSize = width * 0.61;
        }

        boardSize = boardSize.clamp(280.0, 520.0);

        final squareSize = (boardSize - labelSize) / 8;

        final whiteCaptured = capturedPieces.where((p) => p.color == PieceColor.white).toList();
        final blackCaptured = capturedPieces.where((p) => p.color == PieceColor.black).toList();

        Widget capturedPiecesWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CHECK indicator
            if (gameState == GameState.check)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: const Text(
                  '⚠️ CHECK!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            if (blackCaptured.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'White Captured:',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: blackCaptured.map((piece) {
                        return Container(
                          width: 24,
                          height: 24,
                          child: ChessPieceWidget(piece: piece, squareSize: 24),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (whiteCaptured.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Black Captured:',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: whiteCaptured.map((piece) {
                        return Container(
                          width: 24,
                          height: 24,
                          child: ChessPieceWidget(piece: piece, squareSize: 24),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        );

        Widget boardWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: boardSize,
              child: Row(
                children: List.generate(8, (i) {
                  return SizedBox(
                    width: squareSize,
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + i),
                        style: const TextStyle(fontSize: 7, color: Colors.white70),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: labelSize,
                  height: boardSize,
                  child: Column(
                    children: List.generate(8, (i) {
                      return SizedBox(
                        height: squareSize,
                        child: Center(
                          child: Text(
                            '${8 - i}',
                            style: const TextStyle(fontSize: 7, color: Colors.white70),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  width: boardSize - labelSize,
                  height: boardSize - labelSize,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final col = index % 8;
                      final isDark = (row + col) % 2 == 1;
                      final piece = board[index];
                      final isSelected = selectedIndex == index;
                      final isValidMove = validMoves.contains(index);

                      return GestureDetector(
                        onTap: () => onSquareTap(index),
                        child: Stack(
                          children: [
                            ChessSquare(isDark: isDark, highlight: isSelected),
                            if (isValidMove)
                              Center(
                                child: Container(
                                  width: squareSize * 0.3,
                                  height: squareSize * 0.3,
                                  decoration: BoxDecoration(
                                    color: piece == null
                                        ? Colors.green.withOpacity(0.5)
                                        : Colors.red.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            if (piece != null)
                              ChessPieceWidget(piece: piece, squareSize: squareSize),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isDesktop
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      boardWidget,
                      const SizedBox(width: 40),
                      capturedPiecesWidget,
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      boardWidget,
                      const SizedBox(height: 20),
                      capturedPiecesWidget,
                    ],
                  ),
          ),
        );
      },
    );
  }
}