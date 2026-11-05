import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/local_encontrado.dart';
import '../services/geocodificacao_service.dart';
import '../services/gps_service.dart';

/// Estado da tela "Escolher localização" usada no cadastro de lugares.
class BuscaLocalController extends ChangeNotifier {
  final GeocodificacaoService _geo = GeocodificacaoService();
  final GpsService _gps = GpsService();

  List<LocalEncontrado> resultados = [];
  LocalEncontrado? selecionado;
  bool buscando = false;
  String erro = '';

  BuscaLocalController({LatLng? inicial}) {
    if (inicial != null) {
      selecionado = LocalEncontrado(endereco: '', ponto: inicial);
    }
  }

  /// Busca por endereço ou CEP. Se achar, já seleciona o primeiro resultado.
  Future<void> buscar(String texto) async {
    if (texto.trim().isEmpty) return;
    _iniciar();

    try {
      resultados = await _geo.buscar(texto);
      if (resultados.isEmpty) {
        erro = 'Nenhum endereço encontrado. Tente ser mais específico.';
      } else {
        selecionado = resultados.first;
      }
    } catch (e) {
      erro = _limpar(e);
    } finally {
      _terminar();
    }
  }

  void escolher(LocalEncontrado local) {
    selecionado = local;
    resultados = [];
    notifyListeners();
  }

  /// Usuário tocou no mapa: move o pin e descobre o endereço do ponto.
  Future<void> escolherPonto(LatLng ponto) async {
    resultados = [];
    selecionado = LocalEncontrado(endereco: 'Buscando endereço...', ponto: ponto);
    _iniciar();

    try {
      final endereco = await _geo.enderecoDe(ponto);
      selecionado = LocalEncontrado(
        endereco: endereco ?? 'Ponto escolhido no mapa',
        ponto: ponto,
      );
    } catch (_) {
      selecionado = LocalEncontrado(
        endereco: 'Ponto escolhido no mapa',
        ponto: ponto,
      );
    } finally {
      _terminar();
    }
  }

  Future<void> usarMinhaLocalizacao() async {
    _iniciar();
    try {
      final ponto = await _gps.obterLocal();
      _terminar();
      await escolherPonto(ponto);
    } catch (e) {
      erro = _limpar(e);
      _terminar();
    }
  }

  void _iniciar() {
    buscando = true;
    erro = '';
    notifyListeners();
  }

  void _terminar() {
    buscando = false;
    notifyListeners();
  }

  String _limpar(Object erro) {
    final texto = erro.toString().replaceFirst('Exception: ', '');
    // Sem internet / host não encontrado
    if (texto.contains('SocketException') || texto.contains('ClientException')) {
      return 'Sem conexão com o serviço de mapas.';
    }
    return texto;
  }
}
