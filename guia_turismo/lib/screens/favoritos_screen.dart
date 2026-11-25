import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/destinos_controller.dart';
import 'package:guia_turismo/widgets/card_destino.dart';
import 'package:provider/provider.dart';

// aba dos favoritos: mostra so os lugares q o usuario marcou c/ o coracao
// os favoritos ficam salvos no celular, entao continuam msm fechando o app
class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    // escuta o destinos_controller, qnd favorita/desfavorita a lista atualiza sozinha
    return Consumer<DestinosController>(
      builder: (context, destinos, _) {
        final favoritos = destinos.favoritos;

        // ainda carregando a lista da api
        if (destinos.carregando && destinos.destinos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // n tem nenhum favorito: explica como favoritar
        if (favoritos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 72, color: cor.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhum favorito ainda.\n'
                    'Toque no coração de um destino para salvar aqui.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // tem favoritos: monta a lista c/ o msm card da aba destinos
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favoritos.length,
          itemBuilder: (context, indice) =>
              CardDestino(destino: favoritos[indice]),
        );
      },
    );
  }
}
