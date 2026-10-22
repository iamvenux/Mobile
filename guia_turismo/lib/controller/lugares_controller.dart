import 'package:flutter/foundation.dart';

import '../models/lugar_model.dart';
import '../services/lugares_service.dart';
import '../services/session_service.dart';

class LugaresController extends ChangeNotifier {
  final LugaresService _service = LugaresService();
  final SessionService _sessao = SessionService();

  bool carregando = false; // buscando a lista
  bool salvando = false; // enviando um novo lugar
  String erroLista = '';
  String erroCadastro = '';
  String mensagem = ''; // resposta da API ao cadastrar

  List<Lugar> _lugares = [];
  List<Lugar> get lugares => _lugares;

  // Favoritos ficam só em memória (não vão para a API).
  final Set<int> _favoritos = {};
  bool ehFavorito(int id) => _favoritos.contains(id);

  LugaresController() {
    listarLugares();
  }

  Future<void> listarLugares() async {
    carregando = true;
    erroLista = '';
    notifyListeners();

    try {
      _lugares = await _service.buscar();
    } catch (e) {
      erroLista = 'Erro ao listar: ${_limpar(e)}';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  /// Cadastra um lugar e recarrega a lista. Retorna `true` se deu certo.
  Future<bool> cadastrarLugar(Lugar lugar) async {
    salvando = true;
    erroCadastro = '';
    notifyListeners();

    try {
      final token = await _sessao.pegarToken() ?? '';
      mensagem = await _service.cadastrar(lugar, token);
      await listarLugares();
      return true;
    } catch (e) {
      erroCadastro = _limpar(e);
      return false;
    } finally {
      salvando = false;
      notifyListeners();
    }
  }

  void alternarFavorito(int id) {
    if (!_favoritos.remove(id)) _favoritos.add(id);
    notifyListeners();
  }

  String _limpar(Object erro) => erro.toString().replaceFirst('Exception: ', '');
}
