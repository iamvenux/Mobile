import 'package:flutter/material.dart';
import 'package:guia_turismo/controladores/imagem_controle.dart';
import 'package:guia_turismo/servicos/busca_cep.dart';
import 'package:provider/provider.dart';

// aba da camera: tira ou escolhe uma foto do lugar
// e busca a latitude/longitude pelo cep
class TelaFoto extends StatefulWidget {
  const TelaFoto({super.key});

  @override
  State<TelaFoto> createState() => _TelaFotoState();
}

class _TelaFotoState extends State<TelaFoto> {
  // controllers dos campos (cep, lat e long)
  final _cep = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  bool _buscandoCep = false; // p/ trocar a lupa pela bolinha girando enqnt busca

  @override
  // limpa os controllers qnd a tela fecha
  void dispose() {
    _cep.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  // chamado pela lupa ou pelo enter do teclado
  // chama o servico busca_cep e preenche lat/long c/ o resultado
  Future<void> _buscarCep() async {
    if (_cep.text.trim().isEmpty) return; // campo vazio nem busca
    setState(() => _buscandoCep = true);

    String mensagem; // msg q aparece no snackbar no final
    try {
      final local = await BuscaCep().buscar(_cep.text);
      if (local == null) {
        mensagem = 'CEP não encontrado';
      } else {
        // achou: coloca as coordenadas nos campos
        _latitude.text = local['lat'].toString();
        _longitude.text = local['lon'].toString();
        mensagem = local['display_name'] ?? 'Local encontrado'; // display_name eh o endereco completo, mostra p/ conferir se eh o lugar certo
      }
    } catch (e) {
      mensagem = 'Erro ao buscar o CEP';
    }

    if (!mounted) return; // se saiu da tela durante a busca, para aq
    setState(() => _buscandoCep = false);
    // snackbar = aquela barrinha q aparece embaixo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Scaffold(
      // escuta o imagem_controle, qnd a foto muda a tela redesenha
      body: Consumer<ImagemControle>(
        builder: (context, imagemControle, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // caixa da foto c/ o botao da camera em cima (por isso o Stack, q empilha os widgets)
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias, // corta a foto p/ seguir a borda arredondada
                  child: Stack(
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        color: cor.primaryContainer,
                        // 3 opcoes: carregando = bolinha, sem foto = icone, c/ foto = mostra a foto
                        child: imagemControle.carregando
                            ? const Center(child: CircularProgressIndicator())
                            : imagemControle.imagem == null
                                ? Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 80,
                                    color: cor.onPrimaryContainer,
                                  )
                                : Image.file(
                                    imagemControle.imagem!,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      // botaozinho da camera no canto de baixo da caixa
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.small(
                          heroTag: 'foto', // cada botao flutuante precisa de uma heroTag diferente, se n da erro
                          onPressed: () => _abrirOpcoes(imagemControle),
                          child: const Icon(Icons.camera_alt_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tire uma foto do local e busque o CEP.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // campo do cep, a lupa chama o _buscarCep
                TextField(
                  controller: _cep,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _buscarCep(),
                  decoration: InputDecoration(
                    labelText: 'CEP do local',
                    prefixIcon: const Icon(Icons.map_outlined),
                    suffixIcon: _buscandoCep
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _buscarCep,
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // lat e long lado a lado, readOnly pq quem preenche eh a busca do cep
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latitude,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _longitude,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // menu q sobe de baixo c/ as opcoes camera ou galeria
  void _abrirOpcoes(ImagemControle imagemControle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (contextoMenu) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Usar câmera'),
              // fecha o menu e chama a camera pelo imagem_controle
              onTap: () {
                Navigator.pop(contextoMenu);
                imagemControle.usarCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              // fecha o menu e abre a galeria
              onTap: () {
                Navigator.pop(contextoMenu);
                imagemControle.usarGaleria();
              },
            ),
          ],
        ),
      ),
    );
  }
}
