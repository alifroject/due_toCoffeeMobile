import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:due_tocoffee/routes/screen_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ADDED

class EntryPoint extends StatefulWidget {
  final int initialTab;
  EntryPoint({this.initialTab = 0});

  @override
  _EntryPointState createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late int _currentIndex;
  final List<int> _navigationHistory = [];
  bool _isQueueLabelExpanded = false; // NEW

  final List<Widget> _pages = [
    CoffeeShopHome(),
    CartPage(),
    FoodOrderStatusList(),
    ProfilePage(),
  ];

  // ADDED: Variables to store queue info
  List<String> _userQueueNumbers = [];
  bool _isLoadingQueue = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _navigationHistory.add(_currentIndex);
    _setupNotificationListeners();
    _fetchUserQueues(); // ADDED: fetch queue numbers on init
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _navigationHistory.add(index);
      });
    }
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(
          'Notification tapped (background/terminated), data: ${message.data}');
      final action = message.data['action'];
      if (action == 'open_order_status') {
        setState(() {
          _currentIndex = 2;
          _navigationHistory.add(2);
        });
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      print('Notification received in foreground, data: ${message.data}');
      final action = message.data['action'];
      if (action == 'open_order_status') {
        setState(() {
          _currentIndex = 2;
          _navigationHistory.add(2);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("New order status update!"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && message.data['action'] == 'open_order_status') {
        setState(() {
          _currentIndex = 2;
          _navigationHistory.add(2);
        });
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.length > 1) {
      setState(() {
        _navigationHistory.removeLast();
        _currentIndex = _navigationHistory.last;
      });
      return false;
    }
    return true;
  }

  Future<void> _fetchUserQueues() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _userQueueNumbers = [];
          _isLoadingQueue = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('queue')
          .where('userId', isEqualTo: user.uid)
          .where('queue_number_status',
              isEqualTo: 'waiting') // ✅ Only "waiting"
          .get();

      List<String> queues =
          snapshot.docs.map((doc) => doc['queue_number'] as String).toList();

      setState(() {
        _userQueueNumbers = queues;
        _isLoadingQueue = false;
      });
    } catch (e) {
      print("Error fetching queues: $e");
      setState(() {
        _isLoadingQueue = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
            // Masukkan bagian ini di dalam parent seperti Stack
            Positioned(
              bottom: 80,
              right: 16,
              child: (_userQueueNumbers.isNotEmpty || _isLoadingQueue)
                  ? FloatingActionButton.extended(
                      backgroundColor: Colors.blue.shade100,
                      label: Text(
                        _isLoadingQueue
                            ? "Loading..."
                            : "#${_userQueueNumbers.first}",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon:
                          Icon(Icons.confirmation_number, color: Colors.indigo),
                      onPressed: (_userQueueNumbers.isEmpty || _isLoadingQueue)
                          ? null
                          : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24)),
                                ),
                                builder: (context) {
                                  final height =
                                      MediaQuery.of(context).size.height * 0.5;

                                  if (_isLoadingQueue) {
                                    return Container(
                                      height: height,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }

                                  if (_userQueueNumbers.isEmpty) {
                                    return Container(
                                      height: height,
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Queue Number Details",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "You currently have no active queues.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[700]),
                                          ),
                                          SizedBox(height: 32),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: Icon(Icons.close),
                                            label: Text("Close"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.indigo,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return Container(
                                    height: height,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Queue List",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: _userQueueNumbers.length,
                                            itemBuilder: (context, index) {
                                              final queueNum =
                                                  _userQueueNumbers[index];
                                              final isUserOwnQueue = index == 0;

                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 14),
                                                decoration: BoxDecoration(
                                                  color: isUserOwnQueue
                                                      ? Colors.green.shade50
                                                      : Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          Colors.grey.shade200,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.confirmation_number,
                                                      color: isUserOwnQueue
                                                          ? Colors.green
                                                          : Colors.indigo,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Text(
                                                      "Queue Number: #$queueNum",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isUserOwnQueue
                                                            ? Colors
                                                                .green.shade700
                                                            : Colors.indigo,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: Icon(Icons.close),
                                          label: Text("Close"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.indigo,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
        ),
      ),
    );
  }
}
