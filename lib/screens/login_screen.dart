import 'dart:developer';
import 'package:admin_notifier/controllers/api_service.dart';
import 'package:admin_notifier/controllers/storage_manager.dart';
import 'package:admin_notifier/helper_functions.dart';
import 'package:admin_notifier/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mpinController = TextEditingController();
  var _isloading = false;

  @override
  void dispose() {
    phoneController.dispose();
    mpinController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (phoneController.text.isEmpty) {
      showAppSnackbar(context, 'Please enter your complete phone number');
      return;
    }
    if (mpinController.text.isEmpty) {
      showAppSnackbar(context, 'Please enter your complete 6 digit mpin');
      return;
    }
    setState(() {
      _isloading = true;
    });
    String phone = phoneController.text.trim();
    log('Logging in with phone: $phone and mpin: ${mpinController.text}');
    var res = await ApiService().post(
      '/login',
      body: {
        'phoneNumber': phone,
        'mPin': mpinController.text.trim(),
        'deviceId': 'default',
      },
    );
    log(res.toString());
    setState(() {
      _isloading = false;
    });
    showAppSnackbar(context, res['message']);
    if (res['error'] == false) {
      await StorageManager.saveData('phoneNumber', phone);
      await StorageManager.saveData('authToken', res['data']['authToken']);
      context.push(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                maxLength: 10,
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLength: 6,
                controller: mpinController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'mpin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _isloading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: handleLogin,
                    child: const Text('Login'),
                  ),
              TextButton(
                onPressed: () => context.push('/signup'),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
