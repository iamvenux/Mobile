import 'dart:io';

import 'package:flutter/foundation.dart';

import '../services/foto_service.dart';

class FotoController extends ChangeNotifier {
  final FotoService _service = FotoService();

  bool carregando = false;
  File? _foto;
  File? get foto => _foto;

  Future<void> tirarFoto() => _buscar(_service.daCamera);

  Future<void> escolherDaGaleria() => _buscar(_service.daGaleria);

  Future<void> _buscar(Future<File?> Function() origem) async {
    carregando = true;
    notifyListeners();
    try {
      final novaFoto = await origem();
      // Se o usuário cancelar, mantém a foto que já estava.
      if (novaFoto != null) _foto = novaFoto;
    } catch (e) {
      debugPrint('Erro ao obter a foto: $e');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
