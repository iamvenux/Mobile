import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/lugares_controller.dart';
import '../models/lugar_model.dart';
import 'form_lugar_dialog.dart';

class LugaresScreen extends StatelessWidget {
  const LugaresScreen({super.key});

  void _abrirFormulario(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const FormLugarDialog(),
    );
  }

  void _mostrarDetalhes(BuildContext context, Lugar lugar) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lugar.nome, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(lugar.categoria ?? categoriasLugar[lugar.categoriaId] ?? ''),
            const SizedBox(height: 12),
            if ((lugar.descricao ?? '').isNotEmpty) Text(lugar.descricao!),
            const SizedBox(height: 12),
            Text('Lat: ${lugar.latitude}  |  Long: ${lugar.longitude}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LugaresController>(
        builder: (context, controle, _) {
          // Primeira carga: ainda não tem nada para mostrar
          if (controle.carregando && controle.lugares.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controle.erroLista.isNotEmpty && controle.lugares.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controle.erroLista, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controle.listarLugares,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          // Puxar a lista para baixo recarrega os dados
          return RefreshIndicator(
            onRefresh: controle.listarLugares,
            child: controle.lugares.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Nenhum lugar encontrado')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: controle.lugares.length,
                    itemBuilder: (context, index) {
                      final lugar = controle.lugares[index];
                      final favorito = controle.ehFavorito(lugar.id);
                      return Card(
                        child: ListTile(
                          onTap: () => _mostrarDetalhes(context, lugar),
                          leading: CircleAvatar(
                            child: Icon(iconeDaCategoria(lugar.categoriaId)),
                          ),
                          title: Text(lugar.nome),
                          subtitle: Text(lugar.categoria ?? 'Sem categoria'),
                          trailing: IconButton(
                            onPressed: () =>
                                controle.alternarFavorito(lugar.id),
                            icon: Icon(
                              favorito
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: favorito ? Colors.red : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Novo lugar'),
      ),
    );
  }
}
