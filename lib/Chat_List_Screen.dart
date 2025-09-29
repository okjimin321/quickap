import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_friend_screen.dart';
import 'Chat_Room_Screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key); // [수정] 생성자 수정

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('친구 목록'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFriendScreen()),
              );
            },
            tooltip: '친구 추가',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('friends')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('오른쪽 위 아이콘을 눌러\n친구를 추가해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5)));
          }

          final friends = snapshot.data!.docs;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              var friend = friends[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  friend['email'],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        receiverEmail: friend['email'],
                        receiverUID: friend['uid'],
                        // [삭제] cameras: widget.cameras, 부분 제거
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}