import 'dart:developer';

import 'package:admin_notifier/controllers/api_service.dart';
import 'package:flutter/material.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({Key? key}) : super(key: key);

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> pendingList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingApprovals();
  }

  Future<void> fetchPendingApprovals() async {
    final response = await apiService.post(
      '/pendingapprovals',
      body: {},
      includeTokenInHeader: true,
    );

    // log(response.toString());

    if (response['status'] == 'success' && response['data'] != null) {
      setState(() {
        pendingList = response['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching pending approvals: ${response['message']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Approvals")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : pendingList.isEmpty
              ? const Center(child: Text("No pending approvals."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingList.length,
                itemBuilder: (context, index) {
                  final item = pendingList[index];
                  final isFresh = item['isFresh'] == true;

                  return Card(
                    color: isFresh ? Colors.lightBlue[100] : Colors.red[100],
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(item['phoneNumber'] ?? 'No Number'),
                                const SizedBox(height: 4),
                                Text(isFresh ? 'New User' : 'Existing User'),
                              ],
                            ),
                          ),
                          Text(
                            item['otp'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
