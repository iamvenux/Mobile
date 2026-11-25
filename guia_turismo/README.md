# Guia Turismo — rosa pastel

App Flutter de guia de turismo que usa a API `https://guia.liliaborges.com.br`
(login, lista e cadastro de destinos), com câmera/galeria, busca por CEP e mapa com GPS.

Login de teste da API: `lilia@teste.com` / `senha123`

## Como rodar

```bash
flutter pub get
flutter run
```

## Estrutura de `lib/`

| Pasta / arquivo | O que tem |
|---|---|
| `main.dart` | Inicia o app, os controles (Provider) e as rotas |
| `controladores/` | `login_controle`, `destinos_controle`, `imagem_controle`, `localizacao_controle`, `aparencia_controle` (tema) |
| `servicos/` | `acesso_api` (login), `destinos_api`, `armazenamento_local`, `busca_cep`, `posicao_gps`, `seletor_imagem` |
| `modelos/` | `destino_modelo` (destino da API e categorias) |
| `telas/` | `tela_entrada` (login), `tela_principal` (abas), `tela_foto`, `tela_destinos`, `tela_mapa` |
| `estilo/` | `estilo_widgets` — aparência rosa de cada componente |
