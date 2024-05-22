import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({super.key, required this.sendMessage});

  // Função que será recebida como paramêtro
  final Function({String text, XFile imgFile}) sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  void _reset() {
    //limpa o campo de input
    _controller.clear();
    setState(() {
      //desabilitando o botão de enviar
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // botão para adicionar uma foto
          IconButton(
              onPressed: () async {
                // abrindo opção para tirar foto da camera e pegando a imagem tirada
                final XFile? imgFile = await ImagePicker()
                    .pickImage(source: ImageSource.camera);

                if(imgFile == null) return;
                //Passando o imgFile(foto) para função sendMessage quando ela for chamada
                widget.sendMessage(imgFile: imgFile);
              },
              icon: const Icon(Icons.photo_camera)),
          Expanded(
            // campo para digitar a mensagem que será enviada
            child: TextField(
              controller: _controller,
              decoration:
                  // collapsed deixa o campo bem justo
                  const InputDecoration.collapsed(hintText: "Enviar uma Mensagem"),
              // sempre que o dado sendo digitado mudar
              onChanged: (text) {
                setState(() {
                  // para habilita/desabilitar o botão de enviar
                  _isComposing = text.isNotEmpty;
                });
              },
              // quando enviar a mensagem/clicar no enter do teclado
              onSubmitted: (text) {
                widget.sendMessage(text: text);
                _reset();
              },
            ),
          ),
          // botão para enviar a mensagem
          IconButton(
            // se tiver digitando chamará a função, se não, seta null
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: _controller.text);
                    _reset();
                  }
                : null,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
