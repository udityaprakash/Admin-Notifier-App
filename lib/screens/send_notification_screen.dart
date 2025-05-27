import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:admin_notifier/controllers/api_service.dart';
import 'package:admin_notifier/helper_functions.dart';
import 'package:get/get.dart';
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
    dynamic users = await sendNotificationToSelectedUsers(
      context,
      _messageController,
    );
    log('Selected users: $users');
    // Navigator.pop();
    context.pop(true);
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
                              : const Text('Send Message'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    // SizedBox(height: 10),
                    // ElevatedButton.icon(
                    //   onPressed: isSending ? null : _sendNotification,
                    //   icon: const Icon(Icons.send),
                    //   label:
                    //       isSending
                    //           ? const CircularProgressIndicator()
                    //           : const Text('Send Notification to All'),
                    //   style: ElevatedButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 24,
                    //       vertical: 12,
                    //     ),
                    //   ),
                    // ),
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

Future<dynamic> sendNotificationToSelectedUsers(context, msg) async {
  final response = await ApiService().post(
    '/allpeople',
    body: {},
    includeTokenInHeader: true,
  );

  if (response['error'] == true || response['data'] == null) {
    showAppSnackbar(context, 'Failed to fetch users');
    return;
  }

  List<dynamic> users = response['data'];
  List<String> selectedIds = [];
  bool selectAll = false;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Peoples to Send'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Select All'),
                    value: selectAll,
                    onChanged: (bool? value) {
                      setState(() {
                        selectAll = value ?? false;
                        if (selectAll) {
                          selectedIds =
                              users.map((u) => u['_id'].toString()).toList();
                        } else {
                          selectedIds.clear();
                        }
                      });
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userId = user['_id'].toString();
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
                              if (selectedIds.length == users.length) {
                                selectAll = true;
                              } else {
                                selectAll = false;
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedIds.isEmpty && !selectAll) {
                    // showAppSnackbar(context, 'Please select at least one user');
                    return;
                  }

                  if (msg.text.trim().isEmpty) {
                    // showAppSnackbar(context, 'Message cannot be empty');
                    return;
                  }
                  // Navigator.of(dialogContext).pop(selectedIds);
                  if (selectAll) {
                    await ApiService()
                        .post(
                          '/sendNotificationToAll',
                          body: {"message": msg.text},
                          includeTokenInHeader: true,
                        )
                        .then((response) {
                          log(response.toString());
                          // showAppSnackbar(
                          //   context,
                          //   response['message'] ?? 'Notification sent',
                          // );
                        });
                  } else {
                    await ApiService()
                        .post(
                          '/sendNotificationToSelected',
                          body: {"message": msg.text, "userIds": selectedIds},
                          includeTokenInHeader: true,
                        )
                        .then((response) {
                          log(response.toString());
                          // showAppSnackbar(
                          //   context,
                          //   response['message'] ?? 'Notification sent',
                          // );
                        });
                  }
                  Navigator.of(dialogContext).pop(true);
                  // context.pop(true);
                },
                child: const Text('Send Notification'),
              ),
            ],
          );
        },
      );
    },
  );
}
