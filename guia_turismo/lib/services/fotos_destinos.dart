import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// a api da prof n guarda foto, entao a foto de cada lugar fica salva no proprio celular
// funciona assim:
// 1- copia a foto p/ a pasta do app (a do image_picker eh temporaria e pode sumir)
// 2- salva no shared_preferences qual foto eh de qual lugar (pelo id)
// quem chama eh o destinos_controle
class FotosDestinos {
  // copia a foto e liga ela no id do lugar, devolve o caminho novo
  Future<String> salvar(int idDestino, File foto) async {
    final pasta = await getApplicationDocumentsDirectory(); // pasta q so o app usa
    // o timestamp no nome eh p/ n pegar foto velha do cache se trocar a foto
    final caminho =
        '${pasta.path}/destino_${idDestino}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await foto.copy(caminho);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('foto_destino_$idDestino', caminho);
    return caminho;
  }

  // carrega td as fotos salvas, devolve um map id -> caminho da foto
  Future<Map<int, String>> carregarTodas() async {
    final prefs = await SharedPreferences.getInstance();
    final fotos = <int, String>{};
    for (final chave in prefs.getKeys()) {
      if (!chave.startsWith('foto_destino_')) continue;
      final id = int.tryParse(chave.replaceFirst('foto_destino_', ''));
      final caminho = prefs.getString(chave);
      // so pega se o arquivo ainda existe msm (se apagou o app, por ex, some)
      if (id != null && caminho != null && File(caminho).existsSync()) {
        fotos[id] = caminho;
      }
    }
    return fotos;
  }
}
