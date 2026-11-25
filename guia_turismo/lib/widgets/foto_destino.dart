import 'dart:io';
import 'package:flutter/material.dart';

// fotinho redonda do lugar, usada no card da lista e no pin do mapa
// se o lugar n tem foto mostra um icone no lugar
class FotoDestino extends StatelessWidget {
  final String? caminho; // caminho da foto no celular (pode ser null)
  final double tamanho;

  const FotoDestino({super.key, this.caminho, this.tamanho = 48});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: tamanho / 2,
      backgroundColor: cor.primaryContainer,
      // tem foto: mostra ela. n tem: fica so o fundo rosa c/ o icone
      // o ResizeImage carrega a foto pequenininha (so precisa do tamanho da bolinha)
      backgroundImage: caminho != null
          ? ResizeImage(FileImage(File(caminho!)), width: 200)
          : null,
      child: caminho == null
          ? Icon(Icons.place, color: cor.onPrimaryContainer, size: tamanho / 2)
          : null,
    );
  }
}
