
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'invite_service.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invite Friends')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Permission denied to access contacts.'),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    if (_contacts == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invite Friends')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Invite Friends')),
      body: ListView.builder(
        itemCount: _contacts!.length,
        itemBuilder: (context, index) {
          final contact = _contacts![index];
          final phone =
              contact.phones.isNotEmpty ? contact.phones.first.number : '';
          return ListTile(
            title: Text(contact.displayName),
            subtitle: Text(phone),
            trailing: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (phone.isNotEmpty) {
                  // For now, generate a dummy game ID.
                  // In the online phase, this will be the actual room ID.
                  InviteService.inviteFriend(phone, 'GAME-1234'); 
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No phone number available for this contact.'))
                    );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
