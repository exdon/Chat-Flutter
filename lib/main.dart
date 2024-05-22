import 'package:chat/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDeRexsw-eALXRgHgMR1LxR4Dzopt4fpvo',
      appId: 'id',
      messagingSenderId: 'sendid',
      projectId: 'chatflutter-2fe9b',
      storageBucket: 'chatflutter-2fe9b.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat Flutter",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // definindo a cor de todos os icones do App
        iconTheme: const IconThemeData(color: Colors.blue)
      ),
      home: const ChatScreen(),
    );
  }
}
































