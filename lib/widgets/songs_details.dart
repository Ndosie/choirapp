import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/songs.dart';
import '../widgets/audio_player_widget.dart';

class SongsDetail extends StatelessWidget {
  const SongsDetail(this.audioLink, {Key? key}) : super(key: key);
  final String audioLink;

  @override
  Widget build(BuildContext context) {
    final contents = Provider.of<Songs>(context, listen: false).contents;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        Expanded(
          child: ListView(
            children: [
              ...contents.map((content) {
                return Text(content!);
              }).toList()
            ],
          ),
        ),
        SizedBox(
          height: 50,
          child: Card(
            child: AudioPlayerWidget(audioLink),
            elevation: 4.0,
          ),
        )
      ]),
    );
  }
}
