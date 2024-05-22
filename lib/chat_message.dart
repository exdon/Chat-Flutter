import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.data, required this.mine});

  // Atributo para receber os dados da msg
  final Map<String, dynamic> data;

  // Atributo para verificar quem está enviando a msg se sou eu ou outra pessoa
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    // pegando url da foto salva no Firebase
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              // alinha os filhos(children) a esquerda
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Conteúdo da mensagem
                data["imgUrl"] != null
                    ? Image.network(
                        data["imgUrl"],
                        width: 250,
                      )
                    : Text(
                        data["text"],
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: const TextStyle(fontSize: 16),
                      ),
                // Quem enviou a msg
                Text(
                  data["senderName"],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    // pegando url da foto salva no Firebase
                    backgroundImage: NetworkImage(data["senderPhotoUrl"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
