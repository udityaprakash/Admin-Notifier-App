import 'dart:developer';
import 'package:admin_notifier/controllers/api_service.dart';
import 'package:admin_notifier/controllers/storage_manager.dart';
import 'package:admin_notifier/helper_functions.dart';
import 'package:admin_notifier/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<dynamic> messages = [];
  final ScrollController _scrollController = ScrollController();

  void _logout() async {
    await StorageManager.clearAll();
    context.go('/login');
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchMessages();
      }
    });
  }

  Future<void> fetchMessages() async {
    setState(() => isLoading = true);

    final response = await ApiService().post(
      '/messageHistory?page=$currentPage&limit=10',
      body: {},
      includeTokenInHeader: true,
    );

    log(response.toString());

    if (response['error'] == false && response['data'] != null) {
      List newMessages = response['data'];
      setState(() {
        currentPage++;
        messages.addAll(newMessages);
        hasMore = newMessages.length == 10;
      });
    } else {
      showAppSnackbar(context, 'Failed to load messages');
    }

    setState(() => isLoading = false);
  }

  Widget buildMessageCard(Map message) {
    final rawTimestamp = message['createdAt'];
    final parsedDateTime = DateTime.parse(rawTimestamp).toLocal();
    final formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(parsedDateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          formattedDate,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          message['message'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _refreshMessages() async {
    setState(() {
      currentPage = 1;
      messages.clear();
      hasMore = true;
    });
    await fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.person_3_rounded),
          onTap: () {
            context.push(Routes.profile);
          },
        ),
        title: const Text('Admin Notifier'),
        actions: [
          ElevatedButton(onPressed: _logout, child: const Text('logout')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                (!isLoading && messages.isEmpty)
                    ? Center(
                      child: Text(
                        'No Notifications available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : LiquidPullToRefresh(
                      showChildOpacityTransition: false,
                      onRefresh: _refreshMessages,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < messages.length) {
                            return buildMessageCard(messages[index]);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.sendNotification);
        },
        label: Text('Send Notification'),
        backgroundColor: const Color.fromARGB(255, 114, 191, 255),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Home tapped, do nothing as we're on the home screen
              break;
            case 1:
              context.push(Routes.pendingApproval);
              break;
            case 2:
              context.push(Routes.registeredUsers);
              break;
            // case 3:
            //   context.push('/profile');
            //   break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Pending Approval',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Registered Users',
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
