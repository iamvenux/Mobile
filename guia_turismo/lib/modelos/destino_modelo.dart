// categorias q a api aceita (o numero eh o id q vai no cadastro)
// uso no dropdown do formulario e qnd o destino vem sem o nome da categoria
const Map<int, String> categoriasDestino = {
  1: 'Praias',
  2: 'Points',
  3: 'Ilhas',
  4: 'Gastronomia',
  5: 'Dicas',
};

// modelo de um destino (lugar turistico), eh o "formato" dos dados q vem da api
class DestinoModelo {
  final int id;
  final String nome;
  final String? categoria; // ? = pode vir nulo
  final double latitude;
  final double longitude;
  final String? descricao;
  final int categoriaId;

  DestinoModelo({
    required this.id,
    required this.nome,
    this.categoria = '',
    required this.latitude,
    required this.longitude,
    this.descricao = '',
    required this.categoriaId,
  });

  // nome da categoria p/ mostrar na lista
  // se a api mandou o nome usa ele, se n procura pelo id no map la de cima
  String get nomeCategoria {
    if (categoria != null && categoria!.isNotEmpty) return categoria!;
    return categoriasDestino[categoriaId] ?? 'Outro';
  }

  // transforma o json q vem da api em um DestinoModelo
  // os ?? sao p/ n quebrar se algum campo vier nulo
  factory DestinoModelo.fromJson(Map json) {
    return DestinoModelo(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Sem nome',
      // a lat/long as vezes vem como texto e as vezes como numero, o tryParse aceita os dois
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      descricao: json['descricao'] ?? '',
      // a categoria vem como objeto {nome: ...}, por isso o ['nome']
      categoria: json['categoria'] != null ? json['categoria']['nome'] : '',
      categoriaId: json['categoriaId'] ?? 0,
    );
  }

  // faz o caminho contrario, transforma em json p/ mandar no cadastro
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'categoria': categoria,
      'descricao': descricao,
      'categoriaId': categoriaId,
    };
  }
}
