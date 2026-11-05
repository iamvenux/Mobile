import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Pega a localização atual do aparelho usando o pacote geolocator.
class GpsService {
  /// Retorna a posição atual ou lança uma exceção explicando o problema.
  Future<LatLng> obterLocal() async {
    final ativo = await Geolocator.isLocationServiceEnabled();
    if (!ativo) {
      throw Exception('Ative a localização (GPS) do aparelho.');
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização bloqueada. Libere nas configurações.',
      );
    }

    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (erro) {
      debugPrint('ERRO ao obter posição: $erro');
      throw Exception('Não foi possível obter sua localização.');
    }
  }
}
