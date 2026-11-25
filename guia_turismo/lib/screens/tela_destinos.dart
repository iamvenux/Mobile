import 'package:flutter/material.dart';
import 'package:guia_turismo/controllers/destinos_controle.dart';
import 'package:guia_turismo/controllers/imagem_controle.dart';
import 'package:guia_turismo/models/destino_modelo.dart';
import 'package:guia_turismo/services/busca_cep.dart';
import 'package:guia_turismo/widgets/card_destino.dart';
import 'package:provider/provider.dart';

// aba dos destinos: lista os lugares da api e tem o botao + p/ cadastrar um novo
// o cadastro tem foto (camera ou galeria), q fica salva no celular ligada ao lugar
class TelaDestinos extends StatefulWidget {
  const TelaDestinos({super.key});

  @override
  State<TelaDestinos> createState() => _TelaDestinosState();
}

class _TelaDestinosState extends State<TelaDestinos> {
  // controllers dos campos do formulario
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _cep = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  int _categoriaId = 1; // categoria escolhida no dropdown, comeca na 1 (praias)
  bool _salvando = false; // trava o botao salvar enqnt manda p/ api

  @override
  // limpa os controllers qnd a tela fecha
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _cep.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  // abre o formulario de cadastro (chamado pelo botao +)
  void _abrirFormulario() {
    // limpa td antes p/ n aparecer o q foi digitado da ultima vez
    _nome.clear();
    _descricao.clear();
    _cep.clear();
    _latitude.clear();
    _longitude.clear();
    _categoriaId = 1;
    context.read<ImagemControle>().limpar(); // tira a foto do cadastro anterior

    // o formulario eh um modal q sobe de baixo
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // deixa o modal crescer junto c/ o teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // StatefulBuilder pq o modal precisa atualizar sozinho (a bolinha do salvar)
      // o "atualizar" funciona igual um setState so dele
      builder: (contextoForm) => StatefulBuilder(
        builder: (contextoForm, atualizar) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contextoForm).viewInsets.bottom, // sobe o form o tamanho do teclado p/ ele n tampar os campos
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // titulo do form
                const Text(
                  'Novo Destino',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // foto do lugar: escuta o imagem_controle p/ mostrar a foto escolhida
                Consumer<ImagemControle>(
                  builder: (context, imagem, _) => _CaixaFoto(imagem: imagem),
                ),
                const SizedBox(height: 16),
                // nome
                TextField(
                  controller: _nome,
                  decoration: const InputDecoration(
                    labelText: 'Nome do destino',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                ),
                const SizedBox(height: 16),
                // descricao (maxLines 2 = campo c/ 2 linhas)
                TextField(
                  controller: _descricao,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                // dropdown das categorias, monta os itens a partir do map categoriasDestino do modelo
                DropdownButtonFormField<int>(
                  initialValue: _categoriaId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categoriasDestino.entries
                      .map((c) => DropdownMenuItem(
                            value: c.key,
                            child: Text(c.value),
                          ))
                      .toList(),
                  onChanged: (valor) => _categoriaId = valor ?? 1, // guarda o id q escolheu
                ),
                const SizedBox(height: 16),
                // cep opcional, a lupa chama o _buscarCep e preenche lat/long sozinho
                TextField(
                  controller: _cep,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CEP (opcional)',
                    prefixIcon: const Icon(Icons.map_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _buscarCep(contextoForm),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // lat e long lado a lado (da p/ digitar na mao tbm)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true, // signed deixa digitar o - (aq no brasil a lat/long eh negativa)
                        ),
                        decoration:
                            const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _longitude,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration:
                            const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  // botoes cancelar e salvar no canto direito
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(contextoForm),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _salvando // enqnt salva o botao fica desativado e mostra a bolinha
                          ? null
                          : () => _salvar(contextoForm, atualizar),
                      child: _salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar destino'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // busca o cep usando o servico busca_cep (viacep + nominatim) e preenche lat/long
  Future<void> _buscarCep(BuildContext contextoForm) async {
    String mensagem;
    try {
      final local = await BuscaCep().buscar(_cep.text);
      if (local == null) {
        mensagem = 'CEP não encontrado';
      } else {
        _latitude.text = local['lat'].toString();
        _longitude.text = local['lon'].toString();
        mensagem = local['display_name'] ?? 'Local encontrado';
      }
    } catch (e) {
      mensagem = 'Erro ao buscar o CEP';
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // botao salvar: valida, monta o destino e manda p/ o destinos_controle cadastrar
  Future<void> _salvar(
    BuildContext contextoForm,
    StateSetter atualizar,
  ) async {
    // o replaceAll troca virgula por ponto, se a pessoa digitar -23,5 n da erro
    // tryParse devolve null se n for numero
    final latitude = double.tryParse(_latitude.text.replaceAll(',', '.'));
    final longitude = double.tryParse(_longitude.text.replaceAll(',', '.'));

    // se faltar nome ou as coordenadas nem manda p/ api
    if (_nome.text.trim().isEmpty || latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o nome, a latitude e a longitude.'),
        ),
      );
      return;
    }

    // monta o destino c/ o q foi digitado
    final novo = DestinoModelo(
      id: 0, // o id quem gera eh a api, manda 0 so p/ preencher
      nome: _nome.text.trim(),
      descricao: _descricao.text.trim(),
      latitude: latitude,
      longitude: longitude,
      categoriaId: _categoriaId,
    );

    // pega os controles antes do await (dps do await o context pode n existir mais)
    final destinos = context.read<DestinosControle>();
    final foto = context.read<ImagemControle>().imagem; // foto escolhida (pode ser null)
    atualizar(() => _salvando = true);
    // chama o controle, ele manda p/ api c/ o token, recarrega a lista e salva a foto
    final deuCerto = await destinos.cadastrarDestino(novo, foto: foto);
    _salvando = false;
    if (!mounted || !contextoForm.mounted) return; // se fechou a tela ou o form no meio do caminho, para aq
    atualizar(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(destinos.mensagem)), // msg q a api respondeu (ou o erro)
    );
    if (deuCerto) Navigator.pop(contextoForm); // deu certo: fecha o form. deu errado: deixa aberto p/ corrigir
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // lista: escuta o destinos_controle e mostra conforme o estado dele
      body: Consumer<DestinosControle>(
        builder: (context, destinos, _) {
          // 1a vez carregando: bolinha girando
          if (destinos.carregando && destinos.destinos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // deu erro: mostra a msg e um botao p/ tentar de novo
          if (destinos.erro.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(destinos.erro, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: destinos.listarDestinos,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          // carregou mas veio vazio
          if (destinos.destinos.isEmpty) {
            return const Center(child: Text('Nenhum destino encontrado'));
          }

          // td certo: monta a lista
          // RefreshIndicator = puxar a lista p/ baixo recarrega
          return RefreshIndicator(
            onRefresh: destinos.listarDestinos,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88), // 88 embaixo p/ o ultimo card n ficar atras do botao +
              itemCount: destinos.destinos.length,
              // ListView.builder monta um card p/ cada destino da lista
              // o CardDestino ta na pasta widgets pq a aba favoritos usa ele tbm
              itemBuilder: (context, indice) =>
                  CardDestino(destino: destinos.destinos[indice]),
            ),
          );
        },
      ),
      // botao + q abre o formulario
      floatingActionButton: FloatingActionButton(
        heroTag: 'novoDestino',
        tooltip: 'Novo destino',
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}

// caixa da foto dentro do formulario c/ os botoes de camera e galeria
// separei num widget so p/ o formulario n ficar gigante
class _CaixaFoto extends StatelessWidget {
  final ImagemControle imagem;

  const _CaixaFoto({required this.imagem});

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            color: cor.primaryContainer,
            // 3 opcoes: carregando = bolinha, sem foto = icone, c/ foto = mostra a foto
            child: imagem.carregando
                ? const Center(child: CircularProgressIndicator())
                : imagem.imagem == null
                    ? Icon(
                        Icons.add_a_photo_outlined,
                        size: 56,
                        color: cor.onPrimaryContainer,
                      )
                    : Image.file(
                        imagem.imagem!,
                        fit: BoxFit.cover,
                        cacheWidth: 800, // carrega a foto menor p/ gastar menos memoria
                      ),
          ),
        ),
        const SizedBox(height: 8),
        // botoes q chamam o imagem_controle (q chama o servico seletor_imagem)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: imagem.carregando ? null : imagem.usarCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Câmera'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: imagem.carregando ? null : imagem.usarGaleria,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
