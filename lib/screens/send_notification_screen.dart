import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:admin_notifier/controllers/api_service.dart';
import 'package:admin_notifier/helper_functions.dart';
import 'package:go_router/go_router.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isSending = false;

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSending = true);

    final response = await ApiService().post(
      '/sendNotificationToAll',
      body: {"message": _messageController.text},
      includeTokenInHeader: true,
    );

    setState(() => isSending = false);

    log(response.toString());
    final message = response['message'] ?? 'Unexpected response';
    showAppSnackbar(context, message);

    if (response['error'] == false) {
      _messageController.clear();
      context.pop();
    }
  }

  Future<List<String>?> _sendNotificationToSelectedUsers() async {
    dynamic users = await sendNotificationToSelectedUsers(context);
    log('Selected users: $users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notification Message',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Message cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          isSending ? null : _sendNotificationToSelectedUsers,
                      icon: const Icon(Icons.send),
                      label:
                          isSending
                              ? const CircularProgressIndicator()
                              : const Text('Send to selected users'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: isSending ? null : _sendNotification,
                      icon: const Icon(Icons.send),
                      label:
                          isSending
                              ? const CircularProgressIndicator()
                              : const Text('Send Notification to All'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

Future<dynamic> sendNotificationToSelectedUsers(context) async {
  final response = await ApiService().post(
    '/allpeople',
    body: {}, // or any required body
    includeTokenInHeader: true,
  );

  if (response['error'] == true || response['data'] == null) {
    showAppSnackbar(context, 'Failed to fetch users');
    return;
  }

  List<dynamic> users = response['data'];
  List<String> selectedIds = [];

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Users'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userId = user['_id'];
                  final userName =
                      user['registeredName'] ?? user['name'] ?? 'Unknown';

                  return CheckboxListTile(
                    title: Text(userName),
                    value: selectedIds.contains(userId),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedIds.add(userId);
                        } else {
                          selectedIds.remove(userId);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(selectedIds);
                  log('Selected IDs: $selectedIds');
                  // return selectedIds; // Return selected IDs
                  // ✅ Use parent context here, not dialog context
                  // showAppSnackbar(
                  //   context,
                  //   'Selected ${selectedIds.length} user(s)',
                  // );
                },
                child: const Text('Send Notification'),
              ),
            ],
          );
        },
      );
    },
  );
  ;
}
