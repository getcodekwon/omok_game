
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'game/game_provider.dart';
import 'game/board_widget.dart';
import 'game/omok_logic.dart'; // For Player enum
import 'contacts/contact_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const OmokApp());
}

class OmokApp extends StatelessWidget {
  const OmokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Omok Game',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          useMaterial3: true,
        ),
        home: const GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final winner = context.select<GameProvider, Player?>((p) => p.winner);
    final currentPlayer = context.select<GameProvider, Player>((p) => p.currentPlayer);

    if (winner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Game Over'),
            content: Text('${winner == Player.black ? "Black" : "White"} wins!'),
            actions: [
              TextButton(
                onPressed: () {
                  context.read<GameProvider>().resetGame();
                  Navigator.of(context).pop();
                },
                child: const Text('New Game'),
              ),
            ],
          ),
        );
      });
    }

    final isOnline = context.select<GameProvider, bool>((p) => p.isOnline);
    // We can't easily access _myOnlineRole from here without exposing it in provider
    // Let's assume we can infer it or just add a getter in GameProvider if needed.
    // Actually, let's just show "Online: GameID" if online.
    final gameId = context.select<GameProvider, String?>((p) => p.gameId);

    return Scaffold(
      appBar: AppBar(
        title: Text(isOnline && gameId != null ? 'Omok (Online: $gameId)' : 'Omok (Local)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              final gameId = await context.read<GameProvider>().startOnlineGame();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                     title: const Text('Online Game Created'),
                     content: SelectableText('Game ID: $gameId\n\nShare this code with your friend.'),
                  ),
                );
              }
            },
            tooltip: 'Create Online Game',
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: () {
               TextEditingController _controller = TextEditingController();
               showDialog(
                 context: context,
                 builder: (_) => AlertDialog(
                   title: const Text('Join Online Game'),
                   content: TextField(
                     controller: _controller,
                     decoration: const InputDecoration(hintText: 'Enter Game ID'),
                   ),
                   actions: [
                     TextButton(
                       onPressed: () {
                         context.read<GameProvider>().joinOnlineGame(_controller.text.trim());
                         Navigator.pop(context);
                       },
                       child: const Text('Join'),
                     ) 
                   ],
                 ),
               );
            },
            tooltip: 'Join Online Game',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GameProvider>().resetGame(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Current Turn: ${currentPlayer == Player.black ? "Black" : "White"}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const BoardWidget(),
          ],
        ),
      ),
    );
  }
}
