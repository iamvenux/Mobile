import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Camada de "azulejos" (tiles) do mapa, usada nas duas telas de mapa.
///
/// Usa o mapa do OpenStreetMap. No tema escuro aplica o filtro escuro
/// que já vem no flutter_map (darkModeTileBuilder).
class CamadaMapa extends StatelessWidget {
  const CamadaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;

    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.guia_turismo',
      maxZoom: 19,
      tileBuilder: escuro ? darkModeTileBuilder : null,
    );
  }
}

/// Créditos obrigatórios dos dados do mapa.
class CreditosMapa extends StatelessWidget {
  const CreditosMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return RichAttributionWidget(
      attributions: [
        TextSourceAttribution('OpenStreetMap contributors'),
      ],
    );
  }
}