import 'package:flutter/material.dart';

/// Pin personalizado: gota colorida com o ícone da categoria dentro.
/// A ponta da gota fica embaixo, então o Marker usa Alignment.topCenter.
class PinLugar extends StatelessWidget {
  static const double largura = 44;
  static const double altura = 52;

  final Color cor;
  final IconData icone;

  const PinLugar({super.key, required this.cor, required this.icone});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: altura,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Icon(
            Icons.location_on,
            size: altura,
            color: cor,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          Positioned(
            top: 8.5,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 14, color: cor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bolinha azul com "halo" que mostra onde o usuário está.
class PinUsuario extends StatelessWidget {
  const PinUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
    );
  }
}
