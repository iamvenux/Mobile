import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// pega a localizacao do celular pelo gps
// quem chama eh o localizacao_controle
class PosicaoGps {
  // devolve a latitude/longitude ou null se n conseguir
  Future<LatLng?> obterPosicao() async {
    // 1- ve se o gps ta ligado
    final ativo = await Geolocator.isLocationServiceEnabled();
    if (!ativo) return null;

    // 2- ve se tem permissao, se n tiver pede (aparece aquela janelinha do android)
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    // se o usuario negou, n tem oq fazer
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return null;
    }

    // 3- pega a posicao de vdd
    try {
      final posicao = await Geolocator.getCurrentPosition();
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (erro) {
      debugPrint('Erro ao obter posição: $erro');
      return null;
    }
  }
}
