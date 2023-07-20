import 'package:document_saver_app/firebase_options.dart';
import 'package:document_saver_app/provider/auth_provider.dart';
import 'package:document_saver_app/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: MaterialApp(
        initialRoute:
            FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
        routes: routes,
      ),
    );
  }
}
