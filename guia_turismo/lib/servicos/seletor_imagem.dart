import 'dart:io';
import 'package:image_picker/image_picker.dart';

// abre a camera ou a galeria usando o image_picker
// quem chama eh o imagem_controle
class SeletorImagem {
  final ImagePicker _picker = ImagePicker();

  // abre a galeria e devolve a foto escolhida
  Future<File?> abrirGaleria() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery);
    if (imagem == null) return null; // cancelou
    return File(imagem.path); // transforma o XFile em File p/ conseguir mostrar na tela
  }

  // msm coisa mas abre a camera
  Future<File?> abrirCamera() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.camera);
    if (imagem == null) return null;
    return File(imagem.path);
  }
}
