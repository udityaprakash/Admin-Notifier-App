import 'dart:async';
import 'package:admin_notifier/controllers/api_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? userData;
  String? qrData;
  Timer? qrTimer;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchQrCode();
    qrTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchQrCode();
    });
  }

  @override
  void dispose() {
    qrTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchProfile() async {
    final response = await apiService.post(
      '/profile',
      body: {},
      includeTokenInHeader: true,
    );

    if (response['status'] == 'success' && response['data'] != null) {
      setState(() {
        userData = response['data'];
      });
    } else {
      debugPrint("Error fetching profile: ${response['message']}");
    }
  }

  Future<void> fetchQrCode() async {
    final response = await apiService.post(
      '/qr',
      body: {},
      includeTokenInHeader: true,
    );

    if (response['status'] == 'success' && response['data'] != null) {
      setState(() {
        qrData = response['data']['qrData'];
      });
    } else {
      debugPrint("Error fetching QR code: ${response['message']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body:
          userData == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${userData!['name']}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "MPIN: ${userData!['mPin']}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Number: ${userData!['phoneNumber']}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Account Status: ${!userData!['blocked'] ? 'Active' : 'Blocked'}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    // const Spacer(),
                    Center(
                      child:
                          qrData != null
                              ? QrImageView(
                                data: qrData!,
                                version: QrVersions.auto,
                                size: 200.0,
                              )
                              : const CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
    );
  }
}
