# Cadastro de Produtos (Flutter + sqflite)

Aplicativo Flutter para cadastro de produtos em banco de dados local (SQLite via `sqflite`), baseado no projeto de sala `BancoLocaFlutter`.

## Model

`ProdutoModel` (lib/models/produto_model.dart):
- `id` (int?)
- `nome` (String)
- `descricao` (String)
- `categoria` (String)
- `valor` (double)

## Funcionalidades

- Listar produtos cadastrados
- Cadastrar novo produto
- Editar produto existente
- Excluir produto

## Como rodar

```bash
flutter pub get
flutter run
```

## Estrutura

```
lib/
  main.dart
  models/produto_model.dart
  services/produto_banco.dart
  screens/home_screen.dart
```

## Testando no Windows (sem emulador Android)

O projeto já está preparado para rodar como app desktop Windows, usando `sqflite_common_ffi` (o SQLite puro do sqflite não roda fora de Android/iOS).

```bash
flutter pub get
flutter run -d windows
```

O navegador (Chrome/Edge) **não** é suportado, pois nem `sqflite` nem `sqflite_common_ffi` funcionam na web.
