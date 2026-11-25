import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

// login c/ a conta google pelo firebase (baseado no codigo teste da prof)
// quem chama eh o login_controle
class LoginGoogle {
  // o google_sign_in so pode dar initialize uma vez, essa variavel controla isso
  static bool _iniciado = false;

  // abre a escolha de conta e entra no firebase
  // devolve o usuario (tem nome, email e foto) ou null se cancelar
  Future<User?> entrar() async {
    late final UserCredential resultado;

    if (kIsWeb) {
      // no navegador eh mais facil, abre um popup do google
      resultado = await FirebaseAuth.instance.signInWithPopup(
        GoogleAuthProvider(),
      );
    } else {
      // no celular:
      final googleSignIn = GoogleSignIn.instance;
      if (!_iniciado) {
        await googleSignIn.initialize();
        _iniciado = true;
      }

      // 1- abre a janelinha p/ escolher a conta
      final GoogleSignInAccount conta;
      try {
        conta = await googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        // se fechou a janela sem escolher n eh erro, so volta null
        if (e.code == GoogleSignInExceptionCode.canceled) return null;
        rethrow;
      }
      // 2- pega o idToken q o google devolveu e transforma numa credencial
      final credencial = GoogleAuthProvider.credential(
        idToken: conta.authentication.idToken,
      );

      // 3- entra no firebase c/ essa credencial
      resultado = await FirebaseAuth.instance.signInWithCredential(credencial);
    }

    return resultado.user;
  }

  // sai do google e do firebase (se n sair do google, na proxima ele entra direto sem perguntar a conta)
  Future<void> sair() async {
    if (!kIsWeb) {
      if (!_iniciado) {
        await GoogleSignIn.instance.initialize();
        _iniciado = true;
      }
      await GoogleSignIn.instance.signOut();
    }
    await FirebaseAuth.instance.signOut();
  }

  // ve se tem alguem logado no google agr (o main usa p/ escolher a tela inicial)
  static bool get logado {
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false; // se o firebase n iniciou (ex: no windows) cai aq
    }
  }
}
