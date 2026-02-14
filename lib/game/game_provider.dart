
import 'dart:async';
import 'package:flutter/material.dart';
import '../online/firestore_service.dart';
import 'omok_logic.dart';

class GameProvider extends ChangeNotifier {
  final OmokLogic _logic = OmokLogic();
  final FirestoreService _firestoreService = FirestoreService();
  
  StreamSubscription? _gameSubscription;
  String? _onlineGameId;
  bool _isOnline = false;
  Player _myOnlineRole = Player.none; // Assign when creating/joining

  List<List<Player>> get board => _logic.board;
  Player get currentPlayer => _logic.currentPlayer;
  Player? get winner => _logic.winner;
  bool get isOnline => _isOnline;
  String? get gameId => _onlineGameId;

  void placeStone(int row, int col) {
    if (_isOnline) {
      if (_logic.currentPlayer != _myOnlineRole) return; // Not my turn
    }

    if (_logic.placeStone(row, col)) {
      notifyListeners();
      if (_isOnline && _onlineGameId != null) {
        _firestoreService.updateGameState(
            _onlineGameId!, _logic.board, _logic.currentPlayer, _logic.winner);
      }
    }
  }

  void resetGame() {
    _logic.reset();
    _isOnline = false;
    _onlineGameId = null;
    _myOnlineRole = Player.none;
    _gameSubscription?.cancel();
    notifyListeners();
  }

  Future<String> startOnlineGame() async {
    resetGame();
    _isOnline = true;
    _myOnlineRole = Player.black; // Creator is black
    _onlineGameId = await _firestoreService.createGame();
    _listenToGame(_onlineGameId!);
    notifyListeners();
    return _onlineGameId!;
  }

  Future<void> joinOnlineGame(String gameId) async {
    resetGame();
    await _firestoreService.joinGame(gameId);
    _isOnline = true;
    _myOnlineRole = Player.white; // Joiner is white
    _onlineGameId = gameId;
    _listenToGame(gameId);
    notifyListeners();
  }

  void _listenToGame(String gameId) {
    _gameSubscription = _firestoreService.gameStream(gameId).listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      
      // Update board
      final List<dynamic> flatBoard = data['board'];
      for (int i = 0; i < 15; i++) {
        for (int j = 0; j < 15; j++) {
           int index = i * 15 + j;
           int val = flatBoard[index];
           _logic.board[i][j] = Player.values[val]; // 0: none, 1: black, 2: white
        }
      }

      // Update turn
      _logic.currentPlayer = Player.values[data['currentPlayer']];
      
      // Update winner
      int winnerVal = data['winner'];
      _logic.winner = winnerVal == 0 ? null : Player.values[winnerVal];

      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    _gameSubscription?.cancel();
    super.dispose();
  }
}
