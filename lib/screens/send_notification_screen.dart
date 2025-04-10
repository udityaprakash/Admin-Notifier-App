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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
              ElevatedButton.icon(
                onPressed: isSending ? null : _sendNotification,
                icon: const Icon(Icons.send),
                label:
                    isSending
                        ? const CircularProgressIndicator()
                        : const Text('Send Notification'),
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
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
