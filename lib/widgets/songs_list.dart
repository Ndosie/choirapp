import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/songs.dart';
import '../models/song_detail_args.dart';
import '../screens/edit_song_screen.dart';
import '../screens/song_detail_screen.dart';

class SongsList extends StatelessWidget {
  const SongsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Songs>(
        child: const Center(
          child: Text('There\'s no songs for now!'),
        ),
        builder: (ctx, songsProvider, ch) => songsProvider.songs.isEmpty
            ? ch!
            : ListView.builder(
                itemCount: songsProvider.songs.length,
                itemBuilder: (ctx, i) => ListTile(
                      leading: CircleAvatar(
                        child: Text(songsProvider.songs[i].title[0]),
                      ),
                      title: Text(songsProvider.songs[i].title),
                      subtitle: Text("Mwl.${songsProvider.songs[i].teacher}"),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                    EditSongScreen.routeName,
                                    arguments: songsProvider.songs[i].id);
                              },
                              color: Theme.of(context).primaryColor,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                try {
                                  await Provider.of<Songs>(context,
                                          listen: false)
                                      .deleteSong(songsProvider.songs[i].id);
                                  Scaffold.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                    'Delete successfull!.',
                                    textAlign: TextAlign.center,
                                  )));
                                } catch (error) {
                                  Scaffold.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                    'Delete has failed.',
                                    textAlign: TextAlign.center,
                                  )));
                                }
                              },
                              color: Theme.of(context).errorColor,
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            SongDetailScreen.routeName,
                            arguments: SongDetailArgs(
                                songsProvider.songs[i].lyrics,
                                songsProvider.songs[i].audio));
                      },
                    )));
  }
}
