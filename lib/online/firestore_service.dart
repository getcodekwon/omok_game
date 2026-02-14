
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../game/omok_logic.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new game room
  Future<String> createGame() async {
    final String gameId = const Uuid().v4().substring(0, 8).toUpperCase();
    await _firestore.collection('games').doc(gameId).set({
      'board': List.generate(15 * 15, (_) => 0), // Flat list of 0 (none), 1 (black), 2 (white)
      'currentPlayer': 1, // 1 for black
      'winner': 0, // 0 for none
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'waiting', // waiting, playing, finished
      'blackPlayerId': 'me', // simplistic ID
      'whitePlayerId': null,
    });
    return gameId;
  }

  // Join an existing game room
  Future<void> joinGame(String gameId) async {
    final doc = await _firestore.collection('games').doc(gameId).get();
    if (!doc.exists) throw Exception('Game not found');

    await _firestore.collection('games').doc(gameId).update({
      'whitePlayerId': 'opponent', 
      'status': 'playing',
    });
  }

  // Stream game state
  Stream<DocumentSnapshot<Map<String, dynamic>>> gameStream(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots();
  }

  // Update board state
  Future<void> updateGameState(String gameId, List<List<Player>> board, Player nextPlayer, Player? winner) async {
    // Flatten board
    List<int> flatBoard = [];
    for (var row in board) {
      for (var p in row) {
        flatBoard.add(p.index); // 0: none, 1: black, 2: white
      }
    }

    await _firestore.collection('games').doc(gameId).update({
      'board': flatBoard,
      'currentPlayer': nextPlayer.index,
      'winner': winner?.index ?? 0,
    });
  }
}
