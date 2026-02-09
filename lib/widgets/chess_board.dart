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
    IconData icon = Icons.emoji_events;
    Color iconColor = Colors.amber;

    switch (gameState) {
      case GameState.checkmate:
        final winner = currentTurn == PieceColor.white ? 'Black' : 'White';
        final loser = currentTurn == PieceColor.white ? 'White' : 'Black';
        title = '🏆 Checkmate!';
        message = '$winner wins!\n$loser is defeated.';
        icon = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case GameState.stalemate:
        title = '🤝 Stalemate!';
        message = 'The game is a draw.\nNo legal moves available.';
        icon = Icons.handshake;
        iconColor = Colors.blue;
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.grey[850]!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: iconColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 64,
                      color: iconColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Game stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white10,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Moves:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${fenHistory.length - 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pieces Captured:',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${capturedPieces.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // FEN Display
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'Final Position (FEN)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      iconColor: Colors.white70,
                      collapsedIconColor: Colors.white70,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            currentFEN,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'New Game',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.white24, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child:  Text(
                        'Current Turn: ${currentTurn == PieceColor.white ? "White" : "Black"}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
            ),
            // CHECK indicator
            if (gameState == GameState.check )
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: const Text(
                  'CHECK!',
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
                        return SizedBox(
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
                        return SizedBox(
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
                        child: Draggable<int>(
                          data: index,
                          feedback: piece != null
                              ? Opacity(
                                  opacity: 0.7,
                                  child: Container(
                                    width: squareSize,
                                    height: squareSize,
                                    child: ChessPieceWidget(
                                      piece: piece,
                                      squareSize: squareSize,
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                          childWhenDragging: Stack(
                            children: [
                              ChessSquare(isDark: isDark, highlight: false),
                              if (isValidMove)
                                Center(
                                  child: Container(
                                    width: squareSize * 0.3,
                                    height: squareSize * 0.3,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 255, 255),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onDragStarted: () {
                            setState(() {
                              if (piece != null && piece.color == currentTurn) {
                                selectedIndex = index;
                                validMoves = getValidMoves(index);
                              }
                            });
                          },
                          onDraggableCanceled: (velocity, offset) {
                            setState(() {
                              selectedIndex = null;
                              validMoves = [];
                            });
                          },
                          child: DragTarget<int>(
                            onAccept: (fromIndex) {
                              if (validMoves.contains(index)) {
                                _makeMove(fromIndex, index);
                              }
                            },
                            onWillAccept: (fromIndex) {
                              return fromIndex != null && validMoves.contains(index);
                            },
                            builder: (context, candidateData, rejectedData) {
                              return Stack(
                                children: [
                                  ChessSquare(isDark: isDark, highlight: isSelected ==true ? true : false),
                                  if (isValidMove)
                                    Center(
                                      child: Container(
                                        width: piece == null ? squareSize *0.3 : squareSize,
                                        height: piece == null ? squareSize *0.3 : squareSize,
                                        decoration: BoxDecoration(
                                          color: piece == null
                                              ? const Color.fromARGB(255, 255, 255, 255)
                                              : Colors.red,
                                          shape: piece == null ? BoxShape.circle : BoxShape.rectangle,
                                        ),
                                      ),
                                    ),
                                  if (piece != null)
                                    ChessPieceWidget(piece: piece, squareSize: squareSize),
                                ],
                              );
                            },
                          ),
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