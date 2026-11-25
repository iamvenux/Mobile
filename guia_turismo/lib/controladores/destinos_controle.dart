import 'package:flutter/material.dart';
import 'package:guia_turismo/modelos/destino_modelo.dart';
import 'package:guia_turismo/servicos/armazenamento_local.dart';
import 'package:guia_turismo/servicos/destinos_api.dart';

// controle dos destinos: busca a lista da api e cadastra novos
// quem usa eh a tela_destinos (lista) e a tela_mapa (pins)
class DestinosControle extends ChangeNotifier {
  final DestinosApi _api = DestinosApi(); // servico q faz as requisiçoes de vdd
  bool carregando = false; // p/ mostrar a bolinha girando
  String erro = '';
  List<DestinoModelo> _destinos = [];
  List<DestinoModelo> get destinos => _destinos;

  // assim q o controle eh criado (no main) ja busca a lista
  DestinosControle() {
    listarDestinos();
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

  // msg q aparece no snackbar dps de cadastrar (sucesso ou erro)
  String mensagem = '';

  // chamado pelo botao salvar do formulario
  // devolve true se cadastrou, ai a tela fecha o form
  Future<bool> cadastrarDestino(DestinoModelo destino) async {
    // pega o token q foi salvo no login, a api so deixa cadastrar c/ ele
    final token = await ArmazenamentoLocal().pegarToken() ?? '';
    try {
      mensagem = await _api.cadastrarDestino(destino, token);
      await listarDestinos(); // recarrega p/ o novo ja aparecer na lista e no mapa
      return true;
    } catch (e) {
      // tira o "Exception: " da frente p/ ficar mais bonitinho
      mensagem = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }
}
