
enum Player { none, black, white }

class OmokLogic {
  static const int boardSize = 15;
  List<List<Player>> board;
  Player currentPlayer;
  Player? winner;

  OmokLogic()
      : board = List.generate(
          boardSize,
          (_) => List.generate(boardSize, (_) => Player.none),
        ),
        currentPlayer = Player.black;

  void reset() {
    for (var i = 0; i < boardSize; i++) {
      for (var j = 0; j < boardSize; j++) {
        board[i][j] = Player.none;
      }
    }
    currentPlayer = Player.black;
    winner = null;
  }

  bool placeStone(int row, int col) {
    if (winner != null || board[row][col] != Player.none) {
      return false;
    }

    board[row][col] = currentPlayer;
    if (checkWin(row, col)) {
      winner = currentPlayer;
    } else {
      currentPlayer =
          currentPlayer == Player.black ? Player.white : Player.black;
    }
    return true;
  }

  bool checkWin(int row, int col) {
    final player = board[row][col];
    if (player == Player.none) return false;

    // Directions: Horizontal, Vertical, Diagonal (\), Diagonal (/)
    final directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1]
    ];

    for (var dir in directions) {
      int count = 1;
      // Check forward
      for (int i = 1; i < 5; i++) {
        int r = row + dir[0] * i;
        int c = col + dir[1] * i;
        if (r < 0 || r >= boardSize || c < 0 || c >= boardSize || board[r][c] != player) {
          break;
        }
        count++;
      }
      // Check backward
      for (int i = 1; i < 5; i++) {
        int r = row - dir[0] * i;
        int c = col - dir[1] * i;
        if (r < 0 || r >= boardSize || c < 0 || c >= boardSize || board[r][c] != player) {
          break;
        }
        count++;
      }

      if (count >= 5) return true;
    }
    return false;
  }
}
