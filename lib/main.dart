import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'Chat_List_Screen.dart';
import 'package:intl/date_symbol_data_local.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerAccount() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'uid': userCredential.user!.uid,
          'email': _emailController.text.trim().toLowerCase(),
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입에 성공했습니다. 로그인해주세요.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '오류가 발생했습니다.';
      if (e.code == 'weak-password') {
        message = '비밀번호는 6자리 이상이어야 합니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        message = '유효하지 않은 이메일 형식입니다.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알 수 없는 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.white24,
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password (6자리 이상)",
                filled: true,
                fillColor: Colors.white24,
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
                filled: true,
                fillColor: Colors.white24,
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.black,
                )
                    : const Text(
                  '가입하기',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 로그인 박스 위젯
class LoginBox extends StatefulWidget {
  // [삭제] final List<CameraDescription> cameras;
  const LoginBox({Key? key}) : super(key: key); // [수정] 생성자 수정

  @override
  _LoginBoxState createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 성공!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ChatListScreen()), // [수정] cameras 전달 제거
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '이메일 또는 비밀번호가 잘못되었습니다.';
      if (e.code == 'user-not-found') {
        message = '등록되지 않은 이메일입니다.';
      } else if (e.code == 'wrong-password') {
        message = '비밀번호가 틀렸습니다.';
      } else if (e.code == 'invalid-email') {
        message = '유효하지 않은 이메일 형식입니다.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              filled: true,
              fillColor: Colors.white24,
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              filled: true,
              fillColor: Colors.white24,
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                String email = _emailController.text;
                String password = _passwordController.text;

                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이메일과 비밀번호를 모두 입력해주세요.'),
                    ),
                  );
                  return;
                }
                _signIn();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 앱 시작점
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const MyApp()); // [수정] cameras 전달 제거
}

// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  // [삭제] final List<CameraDescription> cameras;
  const MyApp({Key? key}) : super(key: key); // [수정] 생성자 수정

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QUICKAP',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Arial',
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white),
          )),
      home: const LoginScreen(), // [수정] cameras 전달 제거
    );
  }
}

// 로그인 화면 위젯
class LoginScreen extends StatelessWidget {
  // [삭제] final List<CameraDescription> cameras;
  const LoginScreen({Key? key}) : super(key: key); // [수정] 생성자 수정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                const Text(
                  "QUICKAP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 36,
                    letterSpacing: 2.0,
                  ),
                ),
                const Spacer(),
                const LoginBox(), // [수정] cameras 전달 제거
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const Text('|', style: TextStyle(color: Colors.white70)),
                    TextButton(
                      onPressed: () {
                        // TODO: 비밀번호 찾기 페이지로 이동
                      },
                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}