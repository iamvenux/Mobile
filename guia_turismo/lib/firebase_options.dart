// config do firebase, eh o msm q o "flutterfire configure" gera
// os dados vieram do google-services.json do meu projeto (guia-turismo-4bd69)
// so ta configurado p/ android

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  // o main chama isso, ele ve em qual plataforma ta rodando e devolve a config certa
  static FirebaseOptions get currentPlatform {
    // no navegador nao tem config, entao da erro (o main pega esse erro e ignora)
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase não foi configurado para web. '
        'Rode o flutterfire configure marcando web, se precisar.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // qlqr outra plataforma (windows, ios...) tbm da erro
      default:
        throw UnsupportedError(
          'Firebase só foi configurado para Android neste projeto.',
        );
    }
  }

  // chaves do app android no firebase
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrlcHwVFLL5WMZ-dVeeQHRXHOTSJ4xP0Y',
    appId: '1:292142610835:android:7f07643e088fe3c04d1066',
    messagingSenderId: '292142610835',
    projectId: 'guia-turismo-4bd69',
    storageBucket: 'guia-turismo-4bd69.firebasestorage.app',
  );
}
