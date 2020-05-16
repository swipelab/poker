import 'package:firebase_auth/firebase_auth.dart';
import 'package:scoped/scoped.dart';

class App {
  Ref<FirebaseUser> user = Ref();

  init() async {
    FirebaseAuth.instance.onAuthStateChanged.listen(handleAuthStateChanged);
    await FirebaseAuth.instance.currentUser();
  }

  signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'alex@swipelab.co', password: 'cucubau');
  }

  void handleAuthStateChanged(FirebaseUser firebaseUser) {
    user.value = firebaseUser;
  }
}
