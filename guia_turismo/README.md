# Guia Turismo (rosa)

app flutter de guia de turismo usando a api `https://guia.liliaborges.com.br`

login de teste da api: `lilia@teste.com` / `senha123`

## o q tem

- login c/ email e senha (api) e c/ google (firebase), a sessao fica salva e tem botao de sair
- cadastro de lugares c/ foto (camera ou galeria) e busca por cep
- mapa (openstreetmap) c/ a localizacao do usuario e um pin p/ cada lugar (c/ a foto dele)
- distancia ate cada lugar
- favoritos (ficam salvos no celular)
- extra: compartilhar o lugar (whatsapp, email...)
- tema rosa claro e escuro

## como rodar

```bash
flutter pub get
flutter run
```

o firebase so ta configurado p/ android, entao roda no celular ou emulador

## pastas (lib)

| pasta | o q tem |
|---|---|
| `screens/` | telas: entrada (login), principal (abas), destinos, favoritos, mapa |
| `controllers/` | controles c/ provider: login, destinos, localizacao, imagem, aparencia |
| `services/` | api, gps, cep, fotos, favoritos, google, compartilhar |
| `models/` | destino_modelo |
| `widgets/` | card do lugar, pin do mapa, detalhes, foto e o estilo rosa |
