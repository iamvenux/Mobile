import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/foto_controller.dart';

class FotoScreen extends StatelessWidget {
  const FotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FotoController>(
      builder: (context, foto, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 300,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: _preview(context, foto),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: foto.carregando ? null : foto.tirarFoto,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Câmera'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: foto.carregando ? null : foto.escolherDaGaleria,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _preview(BuildContext context, FotoController foto) {
    if (foto.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (foto.foto == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 80),
            SizedBox(height: 8),
            Text('Nenhuma foto selecionada'),
          ],
        ),
      );
    }
    return Image.file(foto.foto!, fit: BoxFit.cover, width: double.infinity);
  }
}
