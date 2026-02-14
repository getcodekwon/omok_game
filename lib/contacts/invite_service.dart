
import 'package:share_plus/share_plus.dart';

class InviteService {
  static Future<void> inviteFriend(String phoneNumber, String gameId) async {
    // specific logic for SMS can be added here if using a specific package, 
    // but share_plus is generic and works well for "inviting".
    // For direct SMS, url_launcher with 'sms:$phoneNumber&body=...' could be used,
    // but Share.share is often better as it lets the user choose the app (WhatsApp, Telegram, SMS).
    
    await Share.share('Reversi/Omok Game Invite! Join me for a game. Game Code: $gameId');
  }
}
