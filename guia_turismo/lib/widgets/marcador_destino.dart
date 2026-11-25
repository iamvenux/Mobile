import 'package:flutter/material.dart';
import 'package:guia_turismo/widgets/foto_destino.dart';

// pin de um lugar no mapa
// se o lugar tem foto, o pin eh a foto redondinha c/ borda
// se n tem, eh o iconezinho de pin normal
// favorito ganha um coracaozinho no canto
class MarcadorDestino extends StatelessWidget {
  final String? foto;
  final bool favorito;
  final VoidCallback aoTocar; // o q acontece qnd toca no pin (abre os detalhes)

  const MarcadorDestino({
    super.key,
    this.foto,
    this.favorito = false,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;
    // rosa um pouco mais escuro p/ aparecer bem no mapa
    final rosaForte = Color.lerp(cor.primary, Colors.black, 0.25)!;

    return GestureDetector(
      onTap: aoTocar,
      child: Stack(
        clipBehavior: Clip.none, // deixa o coracao sair um pouquinho pra fora
        children: [
          foto != null
              ? Container(
                  padding: const EdgeInsets.all(2), // essa eh a borda rosa
                  decoration: BoxDecoration(
                    color: rosaForte,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: FotoDestino(caminho: foto, tamanho: 44),
                )
              : Icon(Icons.location_on, size: 48, color: rosaForte),
          if (favorito)
            const Positioned(
              right: -2,
              top: -2,
              child: Icon(Icons.favorite, size: 18, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }
}
