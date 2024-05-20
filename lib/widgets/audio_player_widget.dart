import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioLink;
  const AudioPlayerWidget(this.audioLink, {Key? key}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioPlayer audioPlayer = AudioPlayer();
  Duration duration = const Duration();
  Duration position = const Duration();
  var _isPlaying = false;
  var _isLoading = false;

  @override
  void dispose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (_isPlaying == false) {
              setState(() {
                _isLoading = true;
              });
            }
            getAudio();
          },
          child: _isPlaying == false
              ? Icon(Icons.play_circle_outline,
                  size: 40, color: Theme.of(context).primaryColor)
              : Icon(Icons.pause_circle_outline,
                  size: 40, color: Theme.of(context).primaryColor),
        ),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Expanded(child: slider())
      ],
    );
  }

  Widget slider() {
    return Slider.adaptive(
        min: 0.0,
        value: position.inSeconds.toDouble(),
        max: duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            audioPlayer.seek(Duration(seconds: value.toInt()));
          });
        });
  }

  void getAudio() async {
    if (widget.audioLink == 'link') {
      showDialogWindow('Audio Link', 'There\'s no the link to audio');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    var splits = widget.audioLink.split('/');

    var url = "https://drive.google.com/uc?export=view&id=${splits[5]}";

    if (_isPlaying) {
      var res = await audioPlayer.pause();
      if (res == 1) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      var res = await audioPlayer.play(url, isLocal: true);
      if (res == 1) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
        });
      } else {
        showDialogWindow(
            'An error occurred!', 'Something went wrong! May be wrong link!!');
      }
    }
    audioPlayer.onDurationChanged.listen((Duration dd) {
      setState(() {
        duration = dd;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((Duration dd) {
      setState(() {
        position = dd;
      });
    });
    audioPlayer.onPlayerCompletion.listen((_) {
      setState(() {
        duration = const Duration();
        position = const Duration();
        _isPlaying = false;
      });
    });
  }

  void showDialogWindow(String title, String msg) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: Text(msg),
              actions: [
                FlatButton(
                  child: const Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ));
  }
}
