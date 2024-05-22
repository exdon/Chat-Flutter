import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Sempre que autenticação mudar, ele retornará o usuário atual logado
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User?> _getUser() async {
    //Retornando o usuário atual
    if (_currentUser != null) return _currentUser;

    // Se não tiver usuário atual, fará o login abaixo
    try {
      // Login com Google
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      // Transformando login do Google no login Firebase
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      // Provider do Google para se autenticar usando ele
      // Caso queira fazer de outros, como Facebook e etc
      // Basta criar outro provider dele
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      // Conexão com Firebase
      // Fazendo login com as credenciais do Google
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Usuário do Firebase
      final User? user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessage({String? text, XFile? imgFile}) async {
    // Pega o usuário logado
    final User? user = await _getUser();

    if (user == null) {
      // Mostrando um SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível fazer o login. Tente novamente!"),
          backgroundColor: Colors.red,
        ),
      );
    }

    Map<String, dynamic> data = {
      // Dados do usuário logado
      "uid": user!.uid, //id único de usuário
      "senderName": user!.displayName, // nome de quem mandou a msg
      "senderPhotoUrl": user!.photoURL, //photo de quem mandou a msg
      "time": Timestamp.now(), // setando a hora da criação da msg
    };

    // Enviando a imagem para o Firebase
    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(
              // Gerando um nome de arquivo único a partir do uid do usuário + o tempo atual em milissegundos do mundo
              user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(File(imgFile.path));

      // Para carregar o Loading da imagem enquanto ela não é exibida
      setState(() {
        _isLoading = true;
      });

      // Traz informações da img salva no Firebase
      TaskSnapshot taskSnapshot = await task;
      // pegando url de download
      String url = await taskSnapshot.ref.getDownloadURL();
      // setando url a variável Map
      data["imgUrl"] = url;

      // Retira o Loading da imagem
      setState(() {
        _isLoading = false;
      });
    }

    // setando o texto digitado a variável Map
    if (text != null) data["text"] = text;

    // Enviando o texto/imagem digitado(s) para o Firebase
    FirebaseFirestore.instance.collection("messages").doc().set(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUser != null
              ? "Olá, ${_currentUser!.displayName}"
              : "Chat App",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  onPressed: () {
                    // Fazendo Logout
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();

                    // Mostrando um SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Você saiu com sucesso!"),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                )
              : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            //StreamBuilder - para que sempre que um dado mudar, ele irá reconstruir
            child: StreamBuilder<QuerySnapshot>(
              // stream retorna o dado sempre que tiver modificação e chama o builder para reconstruir
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .orderBy("time") // ordena o retorno a partir do campo informado
                  .snapshots(),
              builder: (context, snapshot) {
                // Sempre que tiver atualização no stream, essa função será chamada
                switch (snapshot.connectionState) {
                  //Caso os dados ainda não tenham vindo
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  // Caso de sucesso nos dados
                  default:
                    // pegando a lista de documentos retornadas
                    List<DocumentSnapshot> documents = snapshot.data!.docs;

                    // Retornando os dados em um ListView
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          data: documents[index].data() as Map<String, dynamic>,
                          // verifica o uid para saber se sou eu ou outra pessoa que está mandando as msg
                          mine: documents[index].get("uid") == _currentUser?.uid,
                        );
                      },
                      itemCount: documents.length, // qtd de itens da lista
                    );
                }
              },
            ),
          ),
          _isLoading ? const LinearProgressIndicator() : Container(),
          TextComposer(
              // Passando uma função com o texto digitado
              sendMessage: _sendMessage),
        ],
      ),
    );
  }
}
