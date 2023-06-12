import 'package:flutter/material.dart';
import 'package:make_chess/components/piece.dart';
import 'package:make_chess/components/square.dart';
import 'package:make_chess/helper/helper_methods.dart';
import 'package:make_chess/values/colors.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // A 2-D list representing the chessboard
  // with each position possibly containing chess piece
  late List<List<ChessPiece?>> board;

  // the currently selected piece on the chess board,
  // If no piece is selected, this is null
  ChessPiece? selectedPiece;

  // The row index of the selected piece
  // Default value -1 indicated no piece is currently selected
  int selectedRow = -1;

  // The col index of the selected piece
  // Default value -1 indicated no piece is currently selected
  int selectedCol = -1;

  // A list of valid moves for the currently selected piece
  // each move is represented as a list with 2 elements: row and col
  List<List<int>> validMoves = [];

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  // INITIALIZE BOARD
  void _initializeBoard() {
    // initialize the board with nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imgPath: "assets/pawn.png",
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imgPath: "assets/pawn.png",
      );
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imgPath: "assets/rook.png",
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imgPath: "assets/rook.png",
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imgPath: "assets/rook.png",
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imgPath: "assets/rook.png",
    );

    // Place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imgPath: "assets/knight.png",
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imgPath: "assets/knight.png",
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imgPath: "assets/knight.png",
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imgPath: "assets/knight.png",
    );

    // Place bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imgPath: "assets/bishop.png",
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imgPath: "assets/bishop.png",
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imgPath: "assets/bishop.png",
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imgPath: "assets/bishop.png",
    );

    // Place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imgPath: "assets/queen.png",
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imgPath: "assets/queen.png",
    );

    // Place kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imgPath: "assets/king.png",
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imgPath: "assets/king.png",
    );

    board = newBoard;
  }

  // USER SELECT A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // selected a piece if there is a piece in that position
      if (board[row][col] != null) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // if a piece is selected, calculate it's valid moves
      validMoves =
          calculateRawValidMove(selectedRow, selectedCol, selectedPiece);
    });
  }

  // CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMove(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    // different directions based on their color
    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      //* Pawn
      case ChessPieceType.pawn:
        // pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // pawns can 2 square forward if they are at initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // pawns can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;

      //* Rook
      case ChessPieceType.rook:
        // horizontal and vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // kill
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      //* Knight
      case ChessPieceType.knight:
        // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 2
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // kill
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;

      //* Bishop
      case ChessPieceType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 0;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
          }
        }

        break;

      //* Queen
      case ChessPieceType.queen:
        // all eight directions up, down, left, right
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // kill
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;

      //* King
      case ChessPieceType.king:
        // all directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // kill
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }

    return candidateMoves;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: GridView.builder(
        itemCount: 8 * 8,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemBuilder: (context, index) {
          // get the row and col positions of this square
          int row = index ~/ 8;
          int col = index % 8;

          // check if this square is selected
          bool isSelected = selectedRow == row && selectedCol == col;

          // check if the square is valid move or not
          bool isValidMove = false;
          for (var position in validMoves) {
            // compare row and col
            if (position[0] == row && position[1] == col) {
              isValidMove = true;
            }
          }

          return Square(
            isWhite: isWhite(index),
            piece: board[row][col],
            isSelected: isSelected,
            isValidMove: isValidMove,
            onTap: () => pieceSelected(row, col),
          );
        },
      ),
    );
  }
}
