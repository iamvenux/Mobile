import 'package:flutter/material.dart';

/// Categorias aceitas pela API (id -> nome).
const Map<int, String> categoriasLugar = {
  1: 'Praias',
  2: 'Points',
  3: 'Ilhas',
  4: 'Gastronomia',
  5: 'Dicas',
};

/// Ícone usado na lista para cada categoria.
IconData iconeDaCategoria(int categoriaId) {
  switch (categoriaId) {
    case 1:
      return Icons.beach_access;
    case 2:
      return Icons.location_on;
    case 3:
      return Icons.landscape;
    case 4:
      return Icons.restaurant;
    case 5:
      return Icons.lightbulb;
    default:
      return Icons.place;
  }
}

/// Cor do pin no mapa para cada categoria (identidade visual do app).
Color corDaCategoria(int categoriaId) {
  switch (categoriaId) {
    case 1:
      return const Color(0xFF0288D1); // Praias - azul mar
    case 2:
      return const Color(0xFF8E24AA); // Points - roxo
    case 3:
      return const Color(0xFF2E7D32); // Ilhas - verde mata
    case 4:
      return const Color(0xFFEF6C00); // Gastronomia - laranja
    case 5:
      return const Color(0xFFF9A825); // Dicas - amarelo
    default:
      return const Color(0xFF00897B); // teal do tema
  }
}

double _paraDouble(dynamic valor) {
  if (valor is num) return valor.toDouble();
  if (valor is String) return double.tryParse(valor.replaceAll(',', '.')) ?? 0;
  return 0;
}

class Lugar {
  final int id;
  final String nome;
  final String? categoria;
  final int categoriaId;
  final double latitude;
  final double longitude;
  final String? descricao;

  const Lugar({
    required this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.categoriaId,
    this.categoria,
    this.descricao,
  });

  /// Converte o JSON da API em um objeto [Lugar].
  factory Lugar.fromJson(Map<String, dynamic> json) {
    final categoria = json['categoria'];
    return Lugar(
      id: json['id'] as int,
      nome: json['nome']?.toString() ?? '',
      latitude: _paraDouble(json['latitude']),
      longitude: _paraDouble(json['longitude']),
      descricao: json['descricao']?.toString(),
      categoria: categoria is Map ? categoria['nome']?.toString() : null,
      categoriaId: json['categoriaId'] as int? ?? 0,
    );
  }

  /// Lugares sem coordenada (0, 0) não aparecem no mapa.
  bool get temCoordenada => latitude != 0 || longitude != 0;

  /// Converte o objeto em JSON para enviar à API.
  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'latitude': latitude,
        'longitude': longitude,
        'categoria': categoria,
        'descricao': descricao,
        'categoriaId': categoriaId,
      };
}
