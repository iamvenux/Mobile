import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guia_turismo/services/seletor_imagem_service.dart';

// guarda a foto q o usuario tirou ou escolheu da galeria
// o formulario de cadastro (destinos_screen) escuta esse controle p/ mostrar a imagem
class ImagemController extends ChangeNotifier {
  final SeletorImagemService _seletor = SeletorImagemService(); // servico q abre a camera/galeria
  bool carregando = false;
  File? _imagem; // comeca vazia (null)
  File? get imagem => _imagem;

  // as duas fazem a msm coisa, so muda de onde vem a foto
  // por isso as duas chamam o _escolher passando a funcao certa
  Future<void> usarGaleria() => _escolher(_seletor.abrirGaleria);
  Future<void> usarCamera() => _escolher(_seletor.abrirCamera);

  Future<void> _escolher(Future<File?> Function() abrir) async {
    carregando = true;
    notifyListeners();
    try {
      final nova = await abrir();
      // se o usuario cancelar vem null, ai deixa a foto q ja tava
      if (nova != null) _imagem = nova;
    } catch (e) {
      debugPrint('Erro ao pegar imagem: $e');
    } finally {
      carregando = false;
      notifyListeners(); // avisa a tela p/ mostrar a foto nova
    }
  }

  // tira a foto escolhida, o formulario chama isso toda vez q abre
  // p/ n aparecer a foto do ultimo cadastro
  void limpar() {
    _imagem = null;
    notifyListeners();
  }
}
