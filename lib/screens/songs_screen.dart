import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/songs.dart';
import './edit_song_screen.dart';
import '../widgets/songs_list.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  _SongsScreenState createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Songs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditSongScreen.routeName, arguments: '');
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(child: TextField()),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      size: 40,
                    ))
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: Provider.of<Songs>(context, listen: false)
                    .fetchAndSetData(),
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (dataSnapshot.hasError) {
                    return const Center(
                      child: Text("An error has occured!"),
                    );
                  } else {
                    return const SongsList();
                  }
                }),
          ),
        ],
      ),
    );
  }
}
