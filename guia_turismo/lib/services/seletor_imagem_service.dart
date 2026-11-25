import 'dart:io';
import 'package:image_picker/image_picker.dart';

// abre a camera ou a galeria usando o image_picker
// quem chama eh o imagem_controller
class SeletorImagemService {
  final ImagePicker _picker = ImagePicker();

  // a foto vem diminuida (no max 1280px e qualidade 80%)
  // foto grande demais deixava o app sem memoria e o emulador caia
  static const double _tamanhoMax = 1280;
  static const int _qualidade = 80;

  // abre a galeria e devolve a foto escolhida
  Future<File?> abrirGaleria() async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _tamanhoMax,
      maxHeight: _tamanhoMax,
      imageQuality: _qualidade,
    );
    if (imagem == null) return null; // cancelou
    return File(imagem.path); // transforma o XFile em File p/ conseguir mostrar na tela
  }

  // msm coisa mas abre a camera
  Future<File?> abrirCamera() async {
    final XFile? imagem = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _tamanhoMax,
      maxHeight: _tamanhoMax,
      imageQuality: _qualidade,
    );
    if (imagem == null) return null;
    return File(imagem.path);
  }
}
