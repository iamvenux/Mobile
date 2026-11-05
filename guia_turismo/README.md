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

### 2ª entrega — Localização

- **Aba Mapa** (`screens/mapa_screen.dart`): mostra um pin para cada lugar
  cadastrado na API (`flutter_map` + OpenStreetMap)
- **Identidade visual**: pins próprios em formato de gota, com a cor e o ícone
  da categoria; mapa no estilo Voyager da CARTO (e estilo escuro no tema escuro);
  filtro de categorias com chips coloridos; bolinha azul com a posição do usuário
- Toque no pin abre os detalhes do lugar; botões para "ver todos" e
  "minha localização" (`geolocator`)
- **Cadastro com busca no mapa** (`screens/selecionar_local_screen.dart`):
  o botão "Buscar endereço/CEP no mapa" abre um mapa onde dá para buscar por
  endereço ou CEP (API [Nominatim](https://wiki.openstreetmap.org/wiki/Nominatim);
  CEP passa antes pelo [ViaCEP](https://viacep.com.br)), tocar no mapa para
  ajustar o ponto ou usar a localização atual. A latitude e a longitude
  voltam preenchidas no formulário

## Estrutura

```
lib/
├── main.dart              # ponto de entrada, providers e rotas
├── rotas.dart             # nomes das rotas
├── controller/            # estado do app (Provider / ChangeNotifier)
├── models/                # modelo Lugar e categorias
├── screens/               # telas, formulário e mapas
├── services/              # API, sessão, câmera, GPS e geocodificação
├── theme/                 # temas claro e escuro
└── widgets/               # pin personalizado e camada do mapa
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Tecnologias

Flutter, Provider, http, shared_preferences, image_picker, flutter_map,
latlong2, geolocator.
