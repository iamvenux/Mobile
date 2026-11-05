import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../controller/lugares_controller.dart';
import '../models/local_encontrado.dart';
import '../models/lugar_model.dart';
import 'selecionar_local_screen.dart';

/// Janela com o formulário de cadastro de um novo lugar.
class FormLugarDialog extends StatefulWidget {
  const FormLugarDialog({super.key});

  @override
  State<FormLugarDialog> createState() => _FormLugarDialogState();
}

class _FormLugarDialogState extends State<FormLugarDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  int _categoriaId = 1;
  String _endereco = ''; // endereço escolhido no mapa (só para exibir)

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  // Aceita vírgula ou ponto como separador decimal.
  double? _lerNumero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  String? _validarCoordenada(String? texto, double limite, String nome) {
    final valor = _lerNumero(texto ?? '');
    if (valor == null) return 'Informe um número válido';
    if (valor < -limite || valor > limite) {
      return '$nome deve estar entre -${limite.toInt()} e ${limite.toInt()}';
    }
    return null;
  }

  /// Abre o mapa para buscar endereço/CEP e preenche latitude e longitude.
  Future<void> _escolherNoMapa() async {
    final lat = _lerNumero(_latitude.text);
    final lon = _lerNumero(_longitude.text);
    final inicial = (lat != null && lon != null) ? LatLng(lat, lon) : null;

    final local = await Navigator.of(context).push<LocalEncontrado>(
      MaterialPageRoute(builder: (_) => SelecionarLocalScreen(inicial: inicial)),
    );
    if (local == null || !mounted) return;

    setState(() {
      _latitude.text = local.latitude.toStringAsFixed(6);
      _longitude.text = local.longitude.toStringAsFixed(6);
      _endereco = local.endereco;
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final lugares = context.read<LugaresController>();
    final navegador = Navigator.of(context);
    final aviso = ScaffoldMessenger.of(context);

    final novo = Lugar(
      id: 0, // o id é gerado pela API
      nome: _nome.text.trim(),
      descricao: _descricao.text.trim(),
      latitude: _lerNumero(_latitude.text)!,
      longitude: _lerNumero(_longitude.text)!,
      categoriaId: _categoriaId,
    );

    final ok = await lugares.cadastrarLugar(novo);
    if (ok) {
      navegador.pop();
      aviso.showSnackBar(SnackBar(content: Text(lugares.mensagem)));
    }
    // Se deu erro, a mensagem aparece dentro do próprio formulário.
  }

  @override
  Widget build(BuildContext context) {
    final lugares = context.watch<LugaresController>();
    final corErro = Theme.of(context).colorScheme.error;

    return AlertDialog(
      title: const Text('Novo lugar'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricao,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _categoriaId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: categoriasLugar.entries
                    .map((c) =>
                        DropdownMenuItem(value: c.key, child: Text(c.value)))
                    .toList(),
                onChanged: (valor) => _categoriaId = valor ?? 1,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: lugares.salvando ? null : _escolherNoMapa,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Buscar endereço/CEP no mapa'),
                ),
              ),
              if (_endereco.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _endereco,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _latitude,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Latitude'),
                validator: (v) => _validarCoordenada(v, 90, 'Latitude'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitude,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(labelText: 'Longitude'),
                validator: (v) => _validarCoordenada(v, 180, 'Longitude'),
              ),
              if (lugares.erroCadastro.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(lugares.erroCadastro, style: TextStyle(color: corErro)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: lugares.salvando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: lugares.salvando ? null : _salvar,
          child: lugares.salvando
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}
