import 'dart:developer';

import 'package:admin_notifier/controllers/api_service.dart';
import 'package:admin_notifier/controllers/storage_manager.dart';
import 'package:admin_notifier/helper_functions.dart';
import 'package:admin_notifier/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mpinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    mpinController.dispose();
    super.dispose();
  }

  void onsignup() async {
    setState(() {
      _isLoading = true;
    });
    var res = await ApiService().post(
      '/signup',
      body: {
        'name': nameController.text,
        'phoneNumber': phoneController.text.trim(),
        'mPin': mpinController.text.trim(),
      },
    );
    log(res.toString());
    setState(() {
      _isLoading = false;
    });

    showAppSnackbar(context, res["message"].toString());
    if (res["error"] == false) {
      await StorageManager.saveData('phoneNumber', phoneController.text.trim());
      await StorageManager.saveData('authToken', res['data']['authToken']);
      context.push(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLength: 6,
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'mpin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: onsignup, child: const Text('Signup')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Go to Login screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
