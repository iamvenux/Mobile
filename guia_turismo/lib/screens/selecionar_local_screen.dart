import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../controller/busca_local_controller.dart';
import '../models/local_encontrado.dart';
import '../widgets/camada_mapa.dart';
import '../widgets/pin_lugar.dart';

/// Tela para escolher a latitude/longitude de um lugar:
/// busca por endereço ou CEP (Nominatim) ou toque direto no mapa.
/// Ao confirmar, devolve um [LocalEncontrado] com `Navigator.pop`.
class SelecionarLocalScreen extends StatelessWidget {
  final LatLng? inicial;

  const SelecionarLocalScreen({super.key, this.inicial});

  @override
  Widget build(BuildContext context) {
    // Controller só desta tela: é criado ao abrir e descartado ao fechar
    return ChangeNotifierProvider(
      create: (_) => BuscaLocalController(inicial: inicial),
      child: _SelecionarLocalView(inicial: inicial),
    );
  }
}

class _SelecionarLocalView extends StatefulWidget {
  final LatLng? inicial;

  const _SelecionarLocalView({this.inicial});

  @override
  State<_SelecionarLocalView> createState() => _SelecionarLocalViewState();
}

class _SelecionarLocalViewState extends State<_SelecionarLocalView> {
  static const LatLng _centroPadrao = LatLng(-23.5505, -46.6333);

  final _busca = TextEditingController();
  final MapController _mapa = MapController();

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _focar(LocalEncontrado? local) {
    if (local != null) _mapa.move(local.ponto, 16);
  }

  Future<void> _buscar() async {
    FocusScope.of(context).unfocus(); // fecha o teclado
    final controle = context.read<BuscaLocalController>();
    await controle.buscar(_busca.text);
    _focar(controle.selecionado);
  }

  Future<void> _minhaLocalizacao() async {
    final controle = context.read<BuscaLocalController>();
    await controle.usarMinhaLocalizacao();
    _focar(controle.selecionado);
  }

  void _escolherResultado(LocalEncontrado local) {
    context.read<BuscaLocalController>().escolher(local);
    _focar(local);
  }

  @override
  Widget build(BuildContext context) {
    final controle = context.watch<BuscaLocalController>();
    final selecionado = controle.selecionado;
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Escolher localização')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapa,
            options: MapOptions(
              initialCenter: widget.inicial ?? _centroPadrao,
              initialZoom: widget.inicial != null ? 16 : 11,
              onTap: (_, ponto) => controle.escolherPonto(ponto),
            ),
            children: [
              const CamadaMapa(),
              if (selecionado != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selecionado.ponto,
                      width: PinLugar.largura,
                      height: PinLugar.altura,
                      alignment: Alignment.topCenter,
                      child: PinLugar(cor: cores.primary, icone: Icons.star),
                    ),
                  ],
                ),
              const CreditosMapa(),
            ],
          ),

          // Barra de busca + lista de resultados
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _busca,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _buscar(),
                            decoration: const InputDecoration(
                              hintText: 'Endereço ou CEP',
                              prefixIcon: Icon(Icons.search),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Buscar',
                          onPressed: controle.buscando ? null : _buscar,
                          icon: controle.buscando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward),
                        ),
                        IconButton(
                          tooltip: 'Usar minha localização',
                          onPressed:
                              controle.buscando ? null : _minhaLocalizacao,
                          icon: const Icon(Icons.my_location),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controle.erro.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: Icon(Icons.error_outline, color: cores.error),
                      title: Text(controle.erro),
                    ),
                  ),
                // Mais de um resultado: deixa o usuário escolher
                if (controle.resultados.length > 1)
                  Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final local in controle.resultados)
                            ListTile(
                              dense: true,
                              leading: Icon(
                                local == selecionado
                                    ? Icons.radio_button_checked
                                    : Icons.place_outlined,
                                color: cores.primary,
                              ),
                              title: Text(
                                local.endereco,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _escolherResultado(local),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Painel de confirmação
          Positioned(
            left: 12,
            right: 12,
            bottom: 24,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: selecionado == null
                    ? const Row(
                        children: [
                          Icon(Icons.touch_app),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Busque um endereço/CEP ou toque no mapa '
                              'para marcar o local.',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            selecionado.endereco.isEmpty
                                ? 'Local atual do cadastro'
                                : selecionado.endereco,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lat: ${selecionado.latitude.toStringAsFixed(6)}'
                            '  |  Long: ${selecionado.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () =>
                                Navigator.pop(context, selecionado),
                            icon: const Icon(Icons.check),
                            label: const Text('Usar este local'),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
