import 'package:disco_party/firebase_options.dart';
import 'package:disco_party/logics/disco_party_api.dart';
import 'package:disco_party/screens/login.dart';
import 'package:disco_party/widgets/dj_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'variable.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseDatabase.instance.databaseURL =
      dotenv.env['FIREBASE_REALTIME_DATABASE_URL'];

  await DiscoPartyApi().getOrCreateUserInfos(username: 'DJ', id: 'testID');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Scaffold(body: Login()));
  }
}
