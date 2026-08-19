import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_application_1/models/song_data.dart';
export 'package:flutter_application_1/models/song_data.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  int _currentPlaylistIndex = 0;
  int? _currentSongIndex;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isPlaying = false;

  PlaylistProvider() {
    _listenToDuration();
  }

  /// Load persisted data and seed defaults on first launch.
  Future<void> init() async {
    await _loadData();
    if (_playlists.isEmpty) {
      _seedDefaults();
      await _saveData();
    }
    if (currentSongs.isNotEmpty) {
      _currentSongIndex = 0;
      play();
    }
  }

  // ===== Current context =====

  List<Song> get currentSongs =>
      _playlists.isNotEmpty && _currentPlaylistIndex < _playlists.length
          ? _playlists[_currentPlaylistIndex].songs
          : [];

  // ===== Playlist management =====

  void addPlaylist(String name) {
    _playlists.add(Playlist(name: name));
    _saveData();
    notifyListeners();
  }

  Future<void> pickAndAddAudio(int playlistIndex) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio');
    if (!audioDir.existsSync()) audioDir.createSync(recursive: true);

    for (final file in result.files) {
      if (file.path == null) continue;
      final dest = '${audioDir.path}/${file.name}';
      // ponytail: no duplicate-name guard — upgrade: append timestamp to filename
      await File(file.path!).copy(dest);

      _playlists[playlistIndex].songs.add(Song(
        title: file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        artist: 'Unknown',
        album: '',
        audiopath: dest,
        isAsset: false,
      ));
    }
    await _saveData();
    notifyListeners();
  }

  // ===== Playback =====

  void playFromPlaylist(int playlistIndex, int songIndex) {
    _currentPlaylistIndex = playlistIndex;
    _currentSongIndex = songIndex;
    play();
  }

  Future<void> play() async {
    if (_currentSongIndex == null || currentSongs.isEmpty) return;
    if (_currentSongIndex! >= currentSongs.length) _currentSongIndex = 0;

    final song = currentSongs[_currentSongIndex!];
    await _audioPlayer.stop();

    if (song.isAsset) {
      await _audioPlayer.play(AssetSource(song.audiopath));
    } else {
      await _audioPlayer.play(DeviceFileSource(song.audiopath));
    }
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  void pauseOrResume() {
    _isPlaying ? pause() : resume();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void playNext() {
    if (currentSongs.isEmpty) return;
    _currentSongIndex = ((_currentSongIndex ?? -1) + 1) % currentSongs.length;
    play();
  }

  void playPrevious() {
    if (currentSongs.isEmpty) return;
    if (_currentDuration.inSeconds > 1) {
      seek(Duration.zero);
    } else {
      if (_currentSongIndex == null || _currentSongIndex == 0) {
        _currentSongIndex = currentSongs.length - 1;
      } else {
        _currentSongIndex = _currentSongIndex! - 1;
      }
      play();
    }
  }

  // ===== Listeners =====

  void _listenToDuration() {
    _audioPlayer.onDurationChanged.listen((d) {
      _totalDuration = d;
      notifyListeners();
    });
    _audioPlayer.onPositionChanged.listen((p) {
      _currentDuration = p;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) => playNext());
  }

  // ===== Getters =====

  List<Playlist> get playlists => _playlists;
  int get currentPlaylistIndex => _currentPlaylistIndex;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) play();
    notifyListeners();
  }

  // ===== Persistence =====
  // ponytail: single JSON file, no SQLite/Hive — upgrade: migrate to drift if data grows complex

  Future<void> _loadData() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/tone_data.json');
    if (!file.existsSync()) return;
    try {
      final data = jsonDecode(await file.readAsString());
      _playlists = (data['playlists'] as List)
          .map((p) => Playlist.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // ponytail: swallow corrupt JSON — upgrade: show "data corrupted" notice
    }
  }

  Future<void> _saveData() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/tone_data.json');
    await file.writeAsString(jsonEncode({
      'playlists': _playlists.map((p) => p.toJson()).toList(),
    }));
  }

  void _seedDefaults() {
    _playlists.add(Playlist(name: 'hits', songs: [
      Song(
        title: "Starboiiiii",
        artist: "weekdays",
        album: "assets/cover/Starboy.jpg",
        audiopath: "mp4/starboy.mp3",
        quote: "I'm tryna put you in the worst mood, ah",
      ),
      Song(
        title: "Everybody dies",
        artist: "X",
        album: "assets/cover/XXXTentacion.jpg",
        audiopath: "mp4/everybody.mp3",
        quote: "I know you're somewhere, somewhere",
      ),
      Song(
        title: "Wild Flowers",
        artist: "Billie Eilish",
        album: "assets/cover/Billieeilish.jpeg",
        audiopath: "mp4/wildflower.mp3",
        quote: "Did i cross the line?",
      ),
      Song(
        title: "There is a light",
        artist: "the smiths",
        album: "assets/cover/thesmiths.jpg",
        audiopath: "mp4/light.mp3",
        quote: "I know you're somewhere, somewhere",
      ),
      Song(
        title: "Cum Through",
        artist: "pakisthani",
        album: "assets/cover/talha.jpeg",
        audiopath: "mp4/talha.mp3",
        quote: "deppressed shauqeen",
      ),
      Song(
        title: "BAAZ",
        artist: "Talha",
        album: "assets/cover/talha.jpg",
        audiopath: "mp4/baaz.mp3",
        quote: "Harne ko raazi ha, is jeetne ki ",
      ),
    ]));
  }
}

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final PlaylistProvider provider;

  MyAudioHandler(this.provider) {
    provider.addListener(() {
      final songIndex = provider.currentSongIndex;
      if (songIndex != null &&
          provider.currentSongs.isNotEmpty &&
          songIndex < provider.currentSongs.length) {
        final song = provider.currentSongs[songIndex];
        mediaItem.add(MediaItem(
          id: song.audiopath,
          album: "Tone",
          title: song.title,
          artist: song.artist,
        ));
      }

      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          provider.isPlaying ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        playing: provider.isPlaying,
        processingState: AudioProcessingState.ready,
      ));
    });
  }

  @override
  Future<void> play() async => provider.resume();
  @override
  Future<void> pause() async => provider.pause();
  @override
  Future<void> skipToNext() async => provider.playNext();
  @override
  Future<void> skipToPrevious() async => provider.playPrevious();
  @override
  Future<void> seek(Duration position) async => provider.seek(position);
}
