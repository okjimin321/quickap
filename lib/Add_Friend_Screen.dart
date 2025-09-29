import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  // 이메일로 사용자 검색
  void _searchUsers() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // 회원가입할 때도 소문자로 가입
    final searchEmail = _searchController.text.trim().toLowerCase();

    final result = await _firestore
        .collection('users')
        .where('email', isEqualTo: searchEmail)
        .get();

    setState(() {
      _searchResults = result.docs;
      _isLoading = false;
    });
  }

  // 친구 추가 함수
  Future<void> _addFriend(String friendUid, String friendEmail) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    if (currentUser.uid == friendUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('자기 자신은 친구로 추가할 수 없습니다.')),
      );
      return;
    }

    // 1. 내 친구 목록에 상대방 추가
    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .doc(friendUid)
        .set({
      'uid': friendUid,
      'email': friendEmail,
    });

    // 2. 상대방의 친구 목록에 나를 추가 (서로 친구가 됨)
    await _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(currentUser.uid)
        .set({
      'uid': currentUser.uid,
      'email': currentUser.email!.toLowerCase(), // 내 이메일도 소문자로 저장
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$friendEmail 님을 친구로 추가했습니다.')),
    );
    Navigator.pop(context); // 친구 추가 후 이전 화면으로 돌아감
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('친구 추가'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색창
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '친구의 이메일을 입력하세요...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _searchUsers,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 검색 결과
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_searchResults.isEmpty)
              const Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.white70))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    var user = _searchResults[index];
                    var userData = user.data() as Map<String, dynamic>;

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(userData['email'], style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.greenAccent),
                        onPressed: () => _addFriend(userData['uid'], userData['email']),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

