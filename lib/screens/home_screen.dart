import 'dart:developer';
import 'package:admin_notifier/controllers/api_service.dart';
import 'package:admin_notifier/controllers/storage_manager.dart';
import 'package:admin_notifier/helper_functions.dart';
import 'package:admin_notifier/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: const Text(
          'Notification',
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

  Future<void> refreshMessages() async {
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
        title: const Text('Home Page'),
        actions: [
          ElevatedButton(onPressed: _logout, child: const Text('logout')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshMessages,
        child: Column(
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
                      : ListView.builder(
                        controller: _scrollController,
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
          ],
        ),
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
              context.push('/profile');
              break;
            case 2:
              context.push(Routes.pendingApproval);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Approve Users',
          ),
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
