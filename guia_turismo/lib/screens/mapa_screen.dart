import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../controller/lugares_controller.dart';
import '../controller/mapa_controller.dart';
import '../models/lugar_model.dart';
import '../widgets/camada_mapa.dart';
import '../widgets/pin_lugar.dart';

/// Mapa com um pin para cada lugar cadastrado na API.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // Centro usado enquanto os lugares ainda não carregaram (São Paulo).
  static const LatLng _centroPadrao = LatLng(-23.5505, -46.6333);

  final MapController _mapa = MapController();
  bool _mapaPronto = false;
  bool _jaEnquadrou = false;

  /// Ajusta o zoom para todos os pins caberem na tela.
  void _enquadrar(List<Lugar> lugares) {
    if (!_mapaPronto || lugares.isEmpty) return;

    if (lugares.length == 1) {
      final l = lugares.first;
      _mapa.move(LatLng(l.latitude, l.longitude), 15);
      return;
    }

    _mapa.fitCamera(
      CameraFit.coordinates(
        coordinates:
            lugares.map((l) => LatLng(l.latitude, l.longitude)).toList(),
        padding: const EdgeInsets.fromLTRB(48, 96, 48, 48),
        maxZoom: 16,
      ),
    );
  }

  Future<void> _irParaMinhaLocalizacao() async {
    final gps = context.read<MapaController>();
    final aviso = ScaffoldMessenger.of(context);

    await gps.buscarLocal();
    if (gps.atual != null) {
      _mapa.move(gps.atual!, 16);
    } else if (gps.erro.isNotEmpty) {
      aviso.showSnackBar(SnackBar(content: Text(gps.erro)));
    }
  }

  void _mostrarDetalhes(Lugar lugar) {
    _mapa.move(LatLng(lugar.latitude, lugar.longitude), _mapa.camera.zoom);

    final cor = corDaCategoria(lugar.categoriaId);
    final textos = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cor,
                  foregroundColor: Colors.white,
                  child: Icon(iconeDaCategoria(lugar.categoriaId)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lugar.nome, style: textos.titleLarge),
                      Text(
                        lugar.categoria ??
                            categoriasLugar[lugar.categoriaId] ??
                            'Sem categoria',
                        style: textos.labelLarge?.copyWith(color: cor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((lugar.descricao ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(lugar.descricao!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.my_location, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${lugar.latitude.toStringAsFixed(5)}, '
                  '${lugar.longitude.toStringAsFixed(5)}',
                  style: textos.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LugaresController, MapaController>(
      builder: (context, lugaresCtrl, mapaCtrl, _) {
        final visiveis = mapaCtrl.filtrar(lugaresCtrl.lugares);

        // Na primeira vez que os lugares chegam, enquadra todos na tela
        if (_mapaPronto && !_jaEnquadrou && visiveis.isNotEmpty) {
          _jaEnquadrou = true;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _enquadrar(visiveis));
        }

        return Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapa,
                options: MapOptions(
                  initialCenter: _centroPadrao,
                  initialZoom: 11,
                  minZoom: 3,
                  maxZoom: 19,
                  onMapReady: () {
                    if (mounted) setState(() => _mapaPronto = true);
                  },
                ),
                children: [
                  const CamadaMapa(),
                  MarkerLayer(
                    markers: [
                      for (final lugar in visiveis)
                        Marker(
                          point: LatLng(lugar.latitude, lugar.longitude),
                          width: PinLugar.largura,
                          height: PinLugar.altura,
                          alignment: Alignment.topCenter,
                          rotate: true,
                          child: GestureDetector(
                            onTap: () => _mostrarDetalhes(lugar),
                            child: Tooltip(
                              message: lugar.nome,
                              child: PinLugar(
                                cor: corDaCategoria(lugar.categoriaId),
                                icone: iconeDaCategoria(lugar.categoriaId),
                              ),
                            ),
                          ),
                        ),
                      if (mapaCtrl.atual != null)
                        Marker(
                          point: mapaCtrl.atual!,
                          width: 36,
                          height: 36,
                          child: const PinUsuario(),
                        ),
                    ],
                  ),
                  const CreditosMapa(),
                ],
              ),

              // Filtro por categoria (chips coloridos no topo)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: _FiltroCategorias(controle: mapaCtrl),
              ),

              if (lugaresCtrl.carregando)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),

              if (lugaresCtrl.erroLista.isNotEmpty)
                Positioned(
                  top: 64,
                  left: 12,
                  right: 12,
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.cloud_off),
                      title: Text(lugaresCtrl.erroLista),
                      trailing: TextButton(
                        onPressed: lugaresCtrl.listarLugares,
                        child: const Text('Tentar'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'mapa_enquadrar',
                tooltip: 'Ver todos os lugares',
                onPressed: () => _enquadrar(visiveis),
                child: const Icon(Icons.zoom_out_map),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'mapa_gps',
                tooltip: 'Minha localização',
                onPressed: mapaCtrl.carregando ? null : _irParaMinhaLocalizacao,
                child: mapaCtrl.carregando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.my_location),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FiltroCategorias extends StatelessWidget {
  final MapaController controle;

  const _FiltroCategorias({required this.controle});

  @override
  Widget build(BuildContext context) {
    final fundo = Theme.of(context).colorScheme.surface;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final categoria in categoriasLugar.entries)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                showCheckmark: false,
                elevation: 2,
                backgroundColor: fundo,
                // cor da categoria "misturada" no fundo, para ficar opaca
                selectedColor: Color.alphaBlend(
                  corDaCategoria(categoria.key).withValues(alpha: 0.25),
                  fundo,
                ),
                avatar: Icon(
                  iconeDaCategoria(categoria.key),
                  color: corDaCategoria(categoria.key),
                ),
                label: Text(categoria.value),
                selected: controle.categoriaVisivel(categoria.key),
                onSelected: (_) => controle.alternarCategoria(categoria.key),
              ),
            ),
        ],
      ),
    );
  }
}
