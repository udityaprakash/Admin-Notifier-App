import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_notifier/controllers/api_service.dart';
import 'package:admin_notifier/controllers/storage_manager.dart';
import 'package:admin_notifier/helper_functions.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class RegisteredPeoples extends StatefulWidget {
  const RegisteredPeoples({super.key});

  @override
  State<RegisteredPeoples> createState() => _RegisteredPeoplesState();
}

class _RegisteredPeoplesState extends State<RegisteredPeoples> {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<dynamic> users = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchUsers();
      }
    });
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    final response = await ApiService().post(
      '/allpeople?page=$currentPage&limit=10',
      body: {},
      includeTokenInHeader: true,
    );

    log(response.toString());

    if (response['error'] == false && response['data'] != null) {
      List newUsers = response['data'];
      setState(() {
        currentPage++;
        users.addAll(newUsers);
        hasMore = newUsers.length == 10;
      });
    } else {
      showAppSnackbar(context, 'Failed to load users');
    }

    setState(() => isLoading = false);
  }

  Widget buildUserCard(Map user) {
    final createdAt = DateTime.parse(user['createdAt']).toLocal();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(user['registeredName'] ?? 'No Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${user['phoneNumber']}'),
            // Text('Device ID: ${user['deviceId']}'),
            Text('Registered on: $formattedDate'),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshUsers() async {
    setState(() {
      currentPage = 1;
      users.clear();
      hasMore = true;
    });
    await fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registered People')),
      body: Column(
        children: [
          Expanded(
            child:
                (!isLoading && users.isEmpty)
                    ? const Center(
                      child: Text(
                        'No registered users found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : LiquidPullToRefresh(
                      onRefresh: _refreshUsers,
                      showChildOpacityTransition: false,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: users.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < users.length) {
                            return buildUserCard(users[index]);
                          } else {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
