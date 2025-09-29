import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  final String receiverEmail;
  final String receiverUID;

  const ChatRoomScreen({
    Key? key,
    required this.receiverEmail,
    required this.receiverUID,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  // ... (다른 함수들은 이전과 동일)
  Future<void> _sendMessage({required Duration delay}) async {
    if (_messageController.text.isNotEmpty) {
      final String messageText = _messageController.text;
      _messageController.clear();
      final Timestamp sentTimestamp = Timestamp.now();
      final Timestamp deliveryTimestamp = Timestamp.fromMillisecondsSinceEpoch(
          sentTimestamp.millisecondsSinceEpoch + delay.inMilliseconds);
      await _firestore
          .collection('chat_rooms')
          .doc(_getChatRoomId())
          .collection('messages')
          .add({
        'senderUID': _auth.currentUser!.uid,
        'senderEmail': _auth.currentUser!.email,
        'receiverUID': widget.receiverUID,
        'message': messageText,
        'sentTimestamp': sentTimestamp,
        'deliveryTimestamp': deliveryTimestamp,
      });
    }
  }

  void _showDeliveryOptions() {
    if (_messageController.text.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.flash_on, color: Colors.yellowAccent),
                title: const Text('특급 배송 (30분 후)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessage(delay: const Duration(minutes: 30));
                },
              ),
              ListTile(
                leading: const Icon(Icons.send, color: Colors.lightBlueAccent),
                title: const Text('일반 배송 (1시간 후)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessage(delay: const Duration(hours: 1));
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.greenAccent),
                title: const Text('보통 배송 (3시간 후)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessage(delay: const Duration(hours: 3));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getChatRoomId() {
    List<String> ids = [_auth.currentUser!.uid, widget.receiverUID];
    ids.sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildInTransitMessages(), // 수정된 위젯 호출
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chat_rooms')
                  .doc(_getChatRoomId())
                  .collection('messages')
                  .where('deliveryTimestamp',
                  isLessThanOrEqualTo: Timestamp.now())
                  .orderBy('deliveryTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("도착한 편지가 없습니다.",
                          style: TextStyle(color: Colors.white)));
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderUID'] == _auth.currentUser!.uid;
                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.white24,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message['message'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  // --- [수정] 이 위젯을 Container로 감싸고 최대 높이를 지정 ---
  Widget _buildInTransitMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chat_rooms')
          .doc(_getChatRoomId())
          .collection('messages')
          .where('senderUID', isEqualTo: _auth.currentUser!.uid)
          .where('deliveryTimestamp', isGreaterThan: Timestamp.now())
          .orderBy('deliveryTimestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final messages = snapshot.data!.docs;

        // Container로 감싸서 최대 높이를 160으로 제한합니다.
        return Container(
          constraints: const BoxConstraints(maxHeight: 160), // ** 핵심 수정사항 **
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
          ),
          // 내용이 많아지면 스크롤이 가능하도록 다시 ListView.builder를 사용합니다.
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              Timestamp deliveryTimestamp = message['deliveryTimestamp'];
              String formattedTime =
              DateFormat('a h:mm', 'ko_KR').format(deliveryTimestamp.toDate());

              return Opacity(
                opacity: 0.7,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.local_shipping_outlined,
                      color: Colors.white, size: 20),
                  title: Text(
                    '"${message['message']}"',
                    style: const TextStyle(
                        color: Colors.white, fontStyle: FontStyle.italic),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    "$formattedTime 도착 예정",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMessageInputField() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.black,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "편지 쓰기...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _showDeliveryOptions,
            ),
          ],
        ),
      ),
    );
  }
}