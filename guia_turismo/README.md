# Guia Turismo

Aplicativo Flutter de guia de turismo. O usuário faz login, vê a lista de lugares
cadastrados, cadastra novos lugares e pode tirar/escolher uma foto.

Consome a API: https://guia.liliaborges.com.br/api-docs/

## Funcionalidades

- Login com e-mail e senha (token guardado com `shared_preferences`)
- Sessão mantida: se já estiver logado, o app abre direto na tela inicial
- Listagem de lugares com ícone por categoria, detalhes e favoritos
- Cadastro de lugares com validação do formulário (nome e coordenadas)
- Puxar a lista para baixo para atualizar
- Foto pela câmera ou galeria (`image_picker`)
- Tema claro e escuro
- Botão de sair (logout)

## Estrutura

```
lib/
├── main.dart              # ponto de entrada, providers e rotas
├── rotas.dart             # nomes das rotas
├── controller/            # estado do app (Provider / ChangeNotifier)
├── models/                # modelo Lugar e categorias
├── screens/               # telas e formulário
├── services/              # chamadas à API, sessão e câmera
└── theme/                 # temas claro e escuro
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Tecnologias

Flutter, Provider, http, shared_preferences, image_picker.
