import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/songs.dart';

class EditSongScreen extends StatefulWidget {
  const EditSongScreen({Key? key}) : super(key: key);
  static const routeName = '/edit-song';

  @override
  _EditSongScreenState createState() => _EditSongScreenState();
}

class _EditSongScreenState extends State<EditSongScreen> {
  final _form = GlobalKey<FormState>();
  var _editedSong =
      Song(id: '', title: '', lyrics: ' ', audio: '', teacher: '');
  var _isInit = true;
  var _initValues = {'title': '', 'lyrics': '', 'audio': '', 'teacher': ''};
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final songId = ModalRoute.of(context)!.settings.arguments as String;
      if (songId != '') {
        _editedSong =
            Provider.of<Songs>(context, listen: false).findById(songId);
        _initValues = {
          'title': _editedSong.title,
          'lyrics': _editedSong.lyrics,
          'audio': _editedSong.audio,
          'teacher': _editedSong.teacher
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedSong.id != '') {
      try {
        await Provider.of<Songs>(context, listen: false)
            .updateSong(_editedSong.id, _editedSong);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error occurred!'),
                  content: const Text('Something went wrong!'),
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
    } else {
      try {
        await Provider.of<Songs>(context, listen: false).addSong(_editedSong);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error occurred!'),
                  content: const Text('Something went wrong!'),
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
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedSong = Song(
                            id: _editedSong.id,
                            title: value!,
                            lyrics: _editedSong.lyrics,
                            audio: _editedSong.audio,
                            teacher: _editedSong.teacher);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['lyrics'],
                      decoration:
                          const InputDecoration(labelText: 'Lyrics Link'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a lyrics link';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedSong = Song(
                            id: _editedSong.id,
                            title: _editedSong.title,
                            lyrics: value!,
                            audio: _editedSong.audio,
                            teacher: _editedSong.teacher);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['audio'],
                      decoration:
                          const InputDecoration(labelText: 'Audio link'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an audio link';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedSong = Song(
                            id: _editedSong.id,
                            title: _editedSong.title,
                            lyrics: _editedSong.lyrics,
                            audio: value!,
                            teacher: _editedSong.teacher);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['teacher'],
                      decoration:
                          const InputDecoration(labelText: 'Teacher\'s Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the name of the teacher';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedSong = Song(
                          id: _editedSong.id,
                          title: _editedSong.title,
                          lyrics: _editedSong.lyrics,
                          audio: _editedSong.audio,
                          teacher: value!,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
