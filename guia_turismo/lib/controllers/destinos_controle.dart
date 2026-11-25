import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guia_turismo/models/destino_modelo.dart';
import 'package:guia_turismo/services/armazenamento_local.dart';
import 'package:guia_turismo/services/destinos_api.dart';
import 'package:guia_turismo/services/fotos_destinos.dart';

// controle dos destinos: busca a lista da api, cadastra novos,
// cuida dos favoritos e das fotos de cada lugar
// quem usa eh a tela_destinos, a tela_favoritos e a tela_mapa
class DestinosControle extends ChangeNotifier {
  final DestinosApi _api = DestinosApi(); // servico q faz as requisiçoes de vdd
  final FotosDestinos _fotosServico = FotosDestinos(); // salva as fotos no celular
  final ArmazenamentoLocal _armazenamento = ArmazenamentoLocal();

  bool carregando = false; // p/ mostrar a bolinha girando
  String erro = '';
  List<DestinoModelo> _destinos = [];
  List<DestinoModelo> get destinos => _destinos;

  // ids dos lugares favoritados (Set pq n pode ter repetido)
  Set<int> _favoritos = {};
  // fotos de cada lugar: id -> caminho do arquivo no celular
  Map<int, String> _fotos = {};

  // assim q o controle eh criado (no main) ja busca a lista e carrega favoritos/fotos
  DestinosControle() {
    _carregarSalvos();
    listarDestinos();
  }

  // pega os favoritos e as fotos q ficaram salvos no celular
  Future<void> _carregarSalvos() async {
    try {
      _favoritos = await _armazenamento.pegarFavoritos();
      _fotos = await _fotosServico.carregarTodas();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar favoritos/fotos: $e');
    }
  }

  // chama a api e guarda a lista. tbm eh chamado qnd puxa a lista p/ baixo
  Future<void> listarDestinos() async {
    carregando = true;
    erro = '';
    notifyListeners(); // avisa a tela q ta carregando
    try {
      _destinos = await _api.buscarDestinos();
    } catch (e) {
      erro = 'Erro ao listar: $e';
    } finally {
      // da certo ou errado, para de carregar e avisa a tela
      carregando = false;
      notifyListeners();
    }
  }

  // ---------- favoritos ----------

  bool ehFavorito(int id) => _favoritos.contains(id);

  // so os lugares q tao favoritados (a aba favoritos usa)
  List<DestinoModelo> get favoritos =>
      _destinos.where((destino) => _favoritos.contains(destino.id)).toList();

  // clicou no coracao: se ja era favorito tira, se n era coloca
  Future<void> alternarFavorito(int id) async {
    if (_favoritos.contains(id)) {
      _favoritos.remove(id);
    } else {
      _favoritos.add(id);
    }
    notifyListeners(); // o coracao muda na hr
    try {
      await _armazenamento.salvarFavoritos(_favoritos); // e salva p/ n perder qnd fechar o app
    } catch (e) {
      debugPrint('Erro ao salvar favoritos: $e');
    }
  }

  // ---------- fotos ----------

  // caminho da foto do lugar ou null se n tiver
  String? fotoDe(int id) => _fotos[id];

  // ---------- cadastro ----------

  // msg q aparece no snackbar dps de cadastrar (sucesso ou erro)
  String mensagem = '';

  // chamado pelo botao salvar do formulario (a foto eh opcional)
  // devolve true se cadastrou, ai a tela fecha o form
  Future<bool> cadastrarDestino(DestinoModelo destino, {File? foto}) async {
    // pega o token q foi salvo no login, a api so deixa cadastrar c/ ele
    final token = await _armazenamento.pegarToken() ?? '';
    try {
      final (resposta, idNovo) = await _api.cadastrarDestino(destino, token);
      mensagem = resposta;
      await listarDestinos(); // recarrega p/ o novo ja aparecer na lista e no mapa

      // se escolheu foto, salva ela ligada no id do lugar novo
      if (foto != null) {
        final id = idNovo ?? _acharIdDoNovo(destino);
        if (id != null) {
          _fotos[id] = await _fotosServico.salvar(id, foto);
          notifyListeners();
        } else {
          mensagem = '$mensagem (n deu p/ salvar a foto)';
        }
      }
      return true;
    } catch (e) {
      // tira o "Exception: " da frente p/ ficar mais bonitinho
      mensagem = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  // caso a api n mande o id do lugar novo, procura na lista um c/ o msm nome e coordenadas
  // (se tiver mais de um pega o de maior id, q eh o mais novo)
  int? _acharIdDoNovo(DestinoModelo destino) {
    final iguais = _destinos.where(
      (d) =>
          d.nome == destino.nome &&
          (d.latitude - destino.latitude).abs() < 0.00001 &&
          (d.longitude - destino.longitude).abs() < 0.00001,
    );
    if (iguais.isEmpty) return null;
    return iguais.map((d) => d.id).reduce((a, b) => a > b ? a : b);
  }
}
