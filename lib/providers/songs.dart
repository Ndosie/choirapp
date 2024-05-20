import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/docs/v1.dart' as docsV1;
import 'package:googleapis/drive/v2.dart' as driveV2;
import 'package:audioplayers/audioplayers.dart';

import '../models/song.dart';

class Songs with ChangeNotifier {
  GoogleSignInAccount? userAccount;
  final GoogleSignIn? _googleSignIn;

  List<Song> _songs = [];
  final String? token;

  List<String?> _contents = [];
  List<String?> get contents => _contents;

  List<Song> get songs {
    return _songs;
  }

  Songs(this.token, this._songs, this._googleSignIn);

  Song findById(String id) {
    return _songs.firstWhere((song) => song.id == id);
  }

  Future<void> fetchAndSetData() async {
    var url = Uri.parse(
        'https://choir-app-ab724-default-rtdb.firebaseio.com/songs.json?auth=$token&orderBy="title"');

    try {
      final response = await http.get(url);
      final fetchedData = jsonDecode(response.body) as Map<String, dynamic>;
      if (fetchedData.isEmpty) {
        return;
      }
      final List<Song> loadedData = [];
      fetchedData.forEach((songId, song) {
        loadedData.add(Song(
            id: songId,
            title: song['title'],
            lyrics: song['lyrics'],
            audio: song['audio'],
            teacher: song['teacher']));
      });
      _songs = loadedData;
      notifyListeners();
    } catch (error) {
      print(error);
      //throw (error);
    }
  }

  Future<void> addSong(Song song) async {
    final url = Uri.parse(
        'https://choir-app-ab724-default-rtdb.firebaseio.com/songs.json?auth=$token');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': song.title,
          'lyrics': song.lyrics,
          'audio': song.audio,
          'teacher': song.teacher
        }),
      );
      final newSong = Song(
          id: json.decode(response.body)['name'],
          title: song.title,
          lyrics: song.lyrics,
          audio: song.audio,
          teacher: song.teacher);
      _songs.add(newSong);
      notifyListeners();
    } catch (error) {
      print(error);
      //rethrow;
    }
  }

  Future<void> updateSong(String id, Song song) async {
    final songIndex = _songs.indexWhere((song) => song.id == id);
    if (songIndex >= 0) {
      final url = Uri.parse(
          'https://choir-app-ab724-default-rtdb.firebaseio.com/songs/$id.json?auth=$token');
      try {
        await http.patch(
          url,
          body: json.encode({
            'title': song.title,
            'lyrics': song.lyrics,
            'audio': song.audio,
            'teacher': song.teacher
          }),
        );
        _songs[songIndex] = song;
        notifyListeners();
      } catch (error) {
        print(error);
        rethrow;
      }
    } else {
      print('No song');
    }
  }

  Future<void> deleteSong(String id) async {
    final url = Uri.parse(
        'https://choir-app-ab724-default-rtdb.firebaseio.com/songs/$id.json?auth=$token');
    final existingIndex = _songs.indexWhere((prod) => prod.id == id);
    Song? existingProduct = _songs[existingIndex];
    final response = await http.delete(url);
    _songs.removeWhere((prod) => prod.id == id);
    notifyListeners();

    if (response.statusCode >= 400) {
      _songs.insert(existingIndex, existingProduct);
      notifyListeners();
    }
    existingProduct = null;
  }

  Future<void> loadLyrics(String lyrics) async {
    //if (userAccount == null) return;

    var httpClient = (await _googleSignIn!.authenticatedClient())!;
    var splits = lyrics.split('/');

    final docsApi = docsV1.DocsApi(httpClient);
    docsV1.DocumentsResource docs = docsApi.documents;
    var document = await docs.get(splits[5]);

    _contents = [];

    document.body!.content!.forEach((element) {
      element.paragraph?.elements!.forEach((element) {
        _contents.add(element.textRun!.content);
      });
    });
    notifyListeners();
  }

  Future<void> loadAudio(String audio) async {
    var httpClient = (await _googleSignIn!.authenticatedClient())!;
    var splits = audio.split('/');

    final driveApi = driveV2.DriveApi(httpClient);
    driveV2.FilesResource files = driveApi.files;
    var file = await files.export(audio, "audio/m4a");
    print(file!.stream);

    var url = "https://drive.google.com/uc?export=view&id=${splits[5]}";
    print(url);

    //final driveActApi = driveActivity.DriveActivityApi(httpClient);
    //driveActApi.activity(file)
    var audioPlayer = AudioPlayer();
    await audioPlayer.play(url, isLocal: true);
    //notifyListeners();
  }
}
