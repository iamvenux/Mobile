import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/destinos_controller.dart';
import 'package:guia_turismo/controllers/localizacao_controller.dart';
import 'package:guia_turismo/models/destino_model.dart';
import 'package:guia_turismo/services/posicao_gps_service.dart';
import 'package:guia_turismo/widgets/detalhes_destino.dart';
import 'package:guia_turismo/widgets/foto_destino.dart';
import 'package:provider/provider.dart';

// card de um lugar, usado na lista de destinos e na de favoritos
// mostra foto, nome, categoria, distancia e o coracao de favoritar
class CardDestino extends StatelessWidget {
  final DestinoModel destino;

  const CardDestino({super.key, required this.destino});

  @override
  Widget build(BuildContext context) {
    // watch = qnd esses controles mudarem o card redesenha (ex: clicou no coracao)
    final destinos = context.watch<DestinosController>();
    final atual = context.watch<LocalizacaoController>().atual;
    final favorito = destinos.ehFavorito(destino.id);

    // texto de baixo: categoria e, se o gps ja achou o usuario, a distancia
    var subtitulo = 'Categoria: ${destino.nomeCategoria}';
    if (atual != null) {
      subtitulo +=
          ' • ${PosicaoGpsService.distanciaTexto(atual, destino.latitude, destino.longitude)}';
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: FotoDestino(caminho: destinos.fotoDe(destino.id)),
        title: Text(
          destino.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitulo),
        // coracao: cheio se eh favorito, vazio se n eh
        trailing: IconButton(
          tooltip: favorito ? 'Tirar dos favoritos' : 'Favoritar',
          icon: Icon(
            favorito ? Icons.favorite : Icons.favorite_border,
            color: favorito ? Colors.redAccent : null,
          ),
          onPressed: () => destinos.alternarFavorito(destino.id),
        ),
        onTap: () => mostrarDetalhesDestino(context, destino), // abre os detalhes
      ),
    );
  }
}
