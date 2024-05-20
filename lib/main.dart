import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/songs.dart';
import './screens/auth_screen.dart';
import './screens/songs_screen.dart';
import './screens/edit_song_screen.dart';
import './screens/song_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Songs>(
            create: (_) => Songs(null, [], null),
            update: (_, auth, prevSongs) => Songs(auth.token,
                prevSongs == null ? [] : prevSongs.songs, auth.googleSignIn)),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
            title: 'Choir App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.deepPurple,
                accentColor: Colors.deepOrangeAccent,
                fontFamily: 'Lato'),
            home: auth.isAuth ? const SongsScreen() : const AuthScreen(),
            routes: {
              EditSongScreen.routeName: (ctx) => const EditSongScreen(),
              SongDetailScreen.routeName: (ctx) => const SongDetailScreen(),
            }),
      ),
    );
  }
}
