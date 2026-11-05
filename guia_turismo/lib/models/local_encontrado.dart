import 'package:latlong2/latlong.dart';

/// Um endereço encontrado na busca (Nominatim) com sua coordenada.
class LocalEncontrado {
  final String endereco;
  final LatLng ponto;

  const LocalEncontrado({required this.endereco, required this.ponto});

  double get latitude => ponto.latitude;
  double get longitude => ponto.longitude;

  /// Converte um item da resposta do Nominatim.
  factory LocalEncontrado.fromNominatim(Map<String, dynamic> json) {
    return LocalEncontrado(
      endereco: json['display_name']?.toString() ?? 'Local sem nome',
      ponto: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
    );
  }
}
