import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/servicos/posicao_gps.dart';
import 'package:latlong2/latlong.dart';

// controla onde o usuario ta (gps) e mexe no mapa
class LocalizacaoControle extends ChangeNotifier {
  final PosicaoGps _gps = PosicaoGps(); // servico q pega a posicao do celular
  final MapController mapa = MapController(); // controle do mapa, a tela_mapa usa ele no FlutterMap

  LatLng? atual; // posicao do usuario, null ate o gps responder
  bool carregando = false;
  String erro = '';

  // ja busca a posicao assim q o app abre
  LocalizacaoControle() {
    buscarPosicao();
  }

  // pede a posicao p/ o gps. tbm eh chamado pelo botao de "minha posicao" no mapa
  Future<void> buscarPosicao() async {
    carregando = true;
    erro = '';
    notifyListeners();
    try {
      atual = await _gps.obterPosicao();
      if (atual == null) {
        // null = gps desligado ou n deu permissao
        erro = 'Não foi possível pegar sua localização. '
            'Ligue o GPS e permita o acesso.';
      } else {
        irPara(atual!); // achou, entao centraliza o mapa no usuario
      }
    } catch (e) {
      erro = 'Erro ao buscar localização';
      debugPrint('Erro GPS: $e');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  // move o mapa p/ um ponto c/ o zoom q quiser (padrao 15)
  void irPara(LatLng ponto, {double zoom = 15}) {
    try {
      mapa.move(ponto, zoom);
    } catch (_) {
      // se o mapa ainda n apareceu na tela o move da erro, ai so ignora
    }
  }
}
