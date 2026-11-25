import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/destinos_controle.dart';
import 'package:guia_turismo/controllers/localizacao_controle.dart';
import 'package:guia_turismo/models/destino_modelo.dart';
import 'package:guia_turismo/services/compartilhar.dart';
import 'package:guia_turismo/services/posicao_gps.dart';
import 'package:provider/provider.dart';

// abre os detalhes de um lugar num modal q sobe de baixo
// chamado qnd toca num card da lista ou num pin do mapa
// mostra foto, nome, categoria, descricao, distancia e os botoes favoritar/compartilhar
void mostrarDetalhesDestino(BuildContext context, DestinoModelo destino) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _DetalhesDestino(destino: destino),
  );
}

class _DetalhesDestino extends StatelessWidget {
  final DestinoModelo destino;

  const _DetalhesDestino({required this.destino});

  Future<void> _compartilhar(BuildContext context, String? foto) async {
    try {
      await Compartilhar().destino(destino, foto: foto);
    } catch (e) {
      // se der algum erro n trava o app, so avisa
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    // watch p/ o coracao atualizar na hr q clica
    final destinos = context.watch<DestinosControle>();
    final atual = context.watch<LocalizacaoControle>().atual;
    final foto = destinos.fotoDe(destino.id);
    final favorito = destinos.ehFavorito(destino.id);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // o modal fica do tamanho do conteudo
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // foto grande (so se tiver)
            if (foto != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(foto),
                  height: 200,
                  fit: BoxFit.cover,
                  cacheWidth: 800, // carrega a foto menor p/ gastar menos memoria
                  // se a foto der erro p/ abrir, n quebra a tela
                  errorBuilder: (context, erro, pilha) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(destino.nome, style: textos.titleLarge),
            const SizedBox(height: 4),
            Text(destino.nomeCategoria, style: TextStyle(color: cor.outline)),
            if ((destino.descricao ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(destino.descricao!),
            ],
            const SizedBox(height: 12),
            // distancia ate o lugar (so se o gps ja achou o usuario)
            if (atual != null)
              Row(
                children: [
                  Icon(Icons.directions_walk, size: 18, color: cor.outline),
                  const SizedBox(width: 6),
                  Text(
                    'A ${PosicaoGps.distanciaTexto(atual, destino.latitude, destino.longitude)} de você',
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.pin_drop_outlined, size: 18, color: cor.outline),
                const SizedBox(width: 6),
                Text(
                  '${destino.latitude.toStringAsFixed(5)}, ${destino.longitude.toStringAsFixed(5)}',
                  style: TextStyle(color: cor.outline),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // botoes: favoritar e compartilhar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => destinos.alternarFavorito(destino.id),
                    icon: Icon(
                      favorito ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    label: Text(favorito ? 'Favorito' : 'Favoritar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _compartilhar(context, foto),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
