import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// Acesso à câmera e à galeria usando o pacote image_picker.
class FotoService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> daGaleria() => _escolher(ImageSource.gallery);

  Future<File?> daCamera() => _escolher(ImageSource.camera);

  Future<File?> _escolher(ImageSource origem) async {
    final XFile? arquivo = await _picker.pickImage(source: origem);
    return arquivo == null ? null : File(arquivo.path);
  }
}
