import 'dart:async';
import 'package:coffe_shop/core/widgets/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coffe_shop/helpers/fcm_helper.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// ... import tetap sama

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _db = FirebaseDatabase.instance.ref('chats');
  final _typingDb = FirebaseDatabase.instance.ref('typing');
  final _user = FirebaseAuth.instance.currentUser;

  final Map<String, String> _userNames = {};
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String? _typingName;
  Timer? _typingTimer;

  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenTyping();
    _setupKeyboardListeners();
  }

  void _setupKeyboardListeners() {
    _focusNode.addListener(_scrollToBottom);
    KeyboardVisibilityController().onChange.listen((visible) {
      if (!visible) {
        _typingDb.child(_user!.uid).set(false);
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _listenTyping() {
    _typingDb.onValue.listen((event) async {
      final data = event.snapshot.value;
      if (data is Map && data.isNotEmpty) {
        final othersTyping =
            data.entries
                .where((e) => e.key != _user?.uid && e.value == true)
                .map((e) => e.key.toString())
                .toList();

        if (othersTyping.isNotEmpty) {
          final firstUid = othersTyping.first;
          _typingName = await _getUserName(firstUid);
        } else {
          _typingName = null;
        }
        if (mounted) setState(() {});
      } else {
        setState(() => _typingName = null);
      }
    });
  }

  Future<String> _getUserName(String uid) async {
    if (_userNames.containsKey(uid)) return _userNames[uid]!;
    final snapshot =
        await FirebaseDatabase.instance.ref('users/$uid/nama').get();
    final name = snapshot.value?.toString() ?? 'Seseorang';
    _userNames[uid] = name;
    return name;
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final messageData = {
      'senderId': _user?.uid,
      'senderName': _user?.displayName ?? 'Anonim',
      'senderPhoto': _user?.photoURL,
      'message': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await _db.push().set(messageData);
    _controller.clear();
    await _typingDb.child(_user!.uid).set(false);

    await sendFCMv1Notification(
      title: messageData['senderName'].toString(),
      body: messageData['message'].toString(),
    ).catchError((e) => debugPrint('FCM error: $e'));
  }

  void _handleTyping(String value) {
    if (value.isNotEmpty) {
      _typingDb.child(_user!.uid).set(true);
      _resetTypingTimer();
    } else {
      _typingDb.child(_user!.uid).set(false);
    }
  }

  void _resetTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 1), () {
      _typingDb.child(_user!.uid).set(false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingDb.child(_user!.uid).set(false);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Silahkan Login terlebih dahulu',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/login',
                  ); // ganti route sesuai app kamu
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pesan (Chat)'),
          centerTitle: true,
          backgroundColor: CoffeeThemeColors.primary,
          elevation: 0,
          foregroundColor: CoffeeThemeColors.background,
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              if (_typingName != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$_typingName sedang mengetik',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(width: 4),
                      const DotTyping(),
                    ],
                  ),
                ),
              Flexible(
                child: StreamBuilder(
                  stream: _db.orderByChild('timestamp').onValue,
                  builder: (context, snapshot) {
                    final rawData = snapshot.data?.snapshot.value;

                    List<Map<String, dynamic>> messages = [];
                    if (rawData is Map) {
                      messages =
                          rawData.entries
                              .where((e) => e.value is Map)
                              .map(
                                (e) => {
                                  ...Map<String, dynamic>.from(e.value),
                                  'id': e.key,
                                },
                              )
                              .toList()
                            ..sort((a, b) {
                              final tsA = a['timestamp'];
                              final tsB = b['timestamp'];
                              if (tsA is int && tsB is int) {
                                return tsA.compareTo(tsB);
                              }
                              return 0;
                            });
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients &&
                          _lastMessageCount != messages.length) {
                        _scrollToBottom();
                      }
                      _lastMessageCount = messages.length;
                    });

                    final showTypingBubble = _typingName != null;
                    final itemCount =
                        messages.length + (showTypingBubble ? 1 : 0);

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (showTypingBubble && index == messages.length) {
                          return _buildTypingBubble();
                        }

                        final msg = messages[index];
                        final isMe = msg['senderId'] == _user?.uid;
                        return _buildMessageBubble(msg, isMe);
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              _buildInputArea(context),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTypingBubble() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _typingName ?? 'Seseorang',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 6),
          const DotTyping(),
        ],
      ),
    ),
  );

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FutureBuilder<String?>(
                future: _getUserPhotoUrl(msg['senderId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 16,
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    final photoUrl = snapshot.data;
                    return CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          photoUrl != null
                              ? NetworkImage(photoUrl)
                              : const AssetImage('assets/default-avatar.png')
                                  as ImageProvider,
                    );
                  } else {
                    return const CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person),
                    );
                  }
                },
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  msg['senderName'] ?? 'Anonim',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        isMe
                            ? (isDark ? Colors.blue[700] : Colors.blue[100])
                            : (isDark ? Colors.grey[800] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        msg['message'] ?? '',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(msg['timestamp']),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getUserPhotoUrl(String senderId) async {
    final snapshot =
        await FirebaseDatabase.instance.ref('users/$senderId/photoURL').get();
    if (snapshot.exists) {
      return snapshot.value as String?;
    }
    return null; // Return null if no photoUrl exists
  }

  Widget _buildInputArea(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 8,
      right: 8,
      top: 4,
      bottom: MediaQuery.of(context).viewInsets.bottom + 8,
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            focusNode: _focusNode,
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Ketik pesan...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: _handleTyping,
            onSubmitted: (_) => _sendMessage(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
      ],
    ),
  );
}

String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null || timestamp is! int) return '';
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('HH:mm - d MMM').format(dt);
}

class DotTyping extends StatefulWidget {
  const DotTyping({super.key});

  @override
  State<DotTyping> createState() => _DotTypingState();
}

class _DotTypingState extends State<DotTyping>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    _dotCount = IntTween(
      begin: 1,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) => Text('.' * _dotCount.value),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
