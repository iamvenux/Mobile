import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:guia_turismo/controllers/destinos_controle.dart';
import 'package:guia_turismo/controllers/localizacao_controle.dart';
import 'package:guia_turismo/widgets/detalhes_destino.dart';
import 'package:guia_turismo/widgets/marcador_destino.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

// aba do mapa: mostra onde o usuario ta e um pin p/ cada destino da api
// o pin mostra a foto do lugar (se tiver) e tocando abre os detalhes
// eh stateless pq quem guarda as coisas sao os controles
class TelaMapa extends StatelessWidget {
  const TelaMapa({super.key});

  // se o gps ainda n respondeu, o mapa abre no centro de sp
  static const LatLng _centroPadrao = LatLng(-23.5505, -46.6333);

  @override
  Widget build(BuildContext context) {
    // Consumer2 escuta 2 controles ao msm tempo:
    // o de localizacao (gps) e o de destinos (p/ fazer os pins)
    return Consumer2<LocalizacaoControle, DestinosControle>(
      builder: (context, localizacao, destinos, _) => Scaffold(
        // Stack p/ colocar o aviso de erro e o carregando por cima do mapa
        body: Stack(
          children: [
            FlutterMap(
              mapController: localizacao.mapa, // liga o mapa no controle, assim o controle consegue mover ele (irPara)
              options: MapOptions(
                initialCenter: localizacao.atual ?? _centroPadrao,
                initialZoom: 13,
              ),
              children: [
                // as imagens do mapa vem do openstreetmap
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.guia_turismo', // o osm pede p/ identificar o app
                  maxNativeZoom: 19,
                ),

                // pins dos destinos: pra cada destino da lista cria um Marker na lat/long dele
                MarkerLayer(
                  markers: destinos.destinos
                      .map(
                        (destino) {
                          final foto = destinos.fotoDe(destino.id);
                          return Marker(
                            point: LatLng(destino.latitude, destino.longitude),
                            width: 52,
                            height: 52,
                            // pin normal: a ponta fica no lugar. foto redonda: o meio fica no lugar
                            alignment: foto == null
                                ? Alignment.topCenter
                                : Alignment.center,
                            // o pin ta na pasta widgets, tocando nele abre os detalhes do lugar
                            child: MarcadorDestino(
                              foto: foto,
                              favorito: destinos.ehFavorito(destino.id),
                              aoTocar: () =>
                                  mostrarDetalhesDestino(context, destino),
                            ),
                          );
                        },
                      )
                      .toList(),
                ),

                // bolinha azul de onde o usuario ta (so se o gps achou)
                if (localizacao.atual != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: localizacao.atual!,
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),

                // creditos do openstreetmap, é obrigatorio colocar
                SimpleAttributionWidget(
                  source: Text('OpenStreetMap contributors'),
                ),
              ],
            ),

            // bolinha girando enqnt procura o gps
            if (localizacao.carregando)
              const Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(child: CircularProgressIndicator()),
              ),

            // se deu erro no gps mostra um card c/ a msg em cima do mapa
            if (localizacao.erro.isNotEmpty && !localizacao.carregando)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(localizacao.erro, textAlign: TextAlign.center),
                  ),
                ),
              ),
          ],
        ),
        // botao p/ buscar o gps de novo, o controle ja centraliza o mapa sozinho
        floatingActionButton: FloatingActionButton(
          heroTag: 'minhaPosicao',
          tooltip: 'Minha posição',
          onPressed: localizacao.buscarPosicao,
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}
