import 'dart:io';
import 'package:guia_turismo/models/destino_modelo.dart';
import 'package:share_plus/share_plus.dart';

// funcionalidade extra: compartilhar o lugar (whatsapp, email, etc)
// usa o share_plus, q abre aquela janela nativa de compartilhar do celular
// quem chama eh o botao compartilhar dos detalhes do lugar
class Compartilhar {
  Future<void> destino(DestinoModelo destino, {String? foto}) async {
    // link do google maps c/ a lat/long, qm receber clica e ja abre o lugar
    final link =
        'https://www.google.com/maps/search/?api=1&query=${destino.latitude},${destino.longitude}';

    // monta o texto da msg
    final texto = StringBuffer()
      ..writeln('Olha esse lugar q eu achei no Guia Turismo!')
      ..writeln()
      ..writeln(destino.nome)
      ..writeln('Categoria: ${destino.nomeCategoria}');
    if ((destino.descricao ?? '').isNotEmpty) texto.writeln(destino.descricao);
    texto
      ..writeln()
      ..writeln(link);

    // se o lugar tem foto manda ela junto
    final temFoto = foto != null && File(foto).existsSync();
    await SharePlus.instance.share(
      ShareParams(
        text: texto.toString(),
        subject: destino.nome, // usado qnd compartilha por email
        files: temFoto ? [XFile(foto!)] : null,
      ),
    );
  }
}
