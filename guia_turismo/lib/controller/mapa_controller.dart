import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/lugar_model.dart';
import '../services/gps_service.dart';

/// Estado da tela de mapa: localização do usuário e filtro de categorias.
/// Os lugares em si vêm do [LugaresController] (mesma lista da aba Locais).
class MapaController extends ChangeNotifier {
  final GpsService _gps = GpsService();

  LatLng? atual; // onde o usuário está
  bool carregando = false;
  String erro = '';

  // Começa com todas as categorias visíveis
  final Set<int> _categoriasVisiveis = categoriasLugar.keys.toSet();
  bool categoriaVisivel(int id) => _categoriasVisiveis.contains(id);

  void alternarCategoria(int id) {
    if (!_categoriasVisiveis.remove(id)) _categoriasVisiveis.add(id);
    notifyListeners();
  }

  /// Só os lugares com coordenada e de categorias marcadas no filtro.
  List<Lugar> filtrar(List<Lugar> lugares) => lugares
      .where((l) => l.temCoordenada)
      .where((l) =>
          !categoriasLugar.containsKey(l.categoriaId) ||
          _categoriasVisiveis.contains(l.categoriaId))
      .toList();

  Future<void> buscarLocal() async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      atual = await _gps.obterLocal();
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Erro GPS: $erro');
    } finally {
      carregando = false;
      notifyListeners();
    }
  }
}
