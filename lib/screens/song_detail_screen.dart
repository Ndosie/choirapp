import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/songs.dart';
import '../providers/auth.dart';
import '../models/song_detail_args.dart';
import '../widgets/songs_details.dart';
import '../widgets/audio_player_widget.dart';

class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/song-detail';

  @override
  _SongDetailScreen createState() => _SongDetailScreen();
}

class _SongDetailScreen extends State<SongDetailScreen> {
  var _isInit = true;
  var _isLoading = false;
  var _isPlaying = false;
  var audioLink = '';
  AudioPlayer player = AudioPlayer();

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final args = ModalRoute.of(context)!.settings.arguments as SongDetailArgs;
      final lyricsLink = args.lyrics;
      audioLink = args.audio;
      Provider.of<Songs>(context, listen: false)
          .loadLyrics(lyricsLink)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choir App"),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SongsDetail(audioLink),
    );
  }
}
