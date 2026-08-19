import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/playlist_provider.dart';
import 'package:flutter_application_1/pages/song_page.dart';
import 'package:provider/provider.dart';

class PlaylistDetailPage extends StatelessWidget {
  final int playlistIndex;
  const PlaylistDetailPage({super.key, required this.playlistIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        if (playlistIndex >= provider.playlists.length) {
          return const Scaffold(
              body: Center(child: Text('Playlist not found')));
        }
        final playlist = provider.playlists[playlistIndex];
        return Scaffold(
          appBar: AppBar(
            title: Text(playlist.name),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => provider.pickAndAddAudio(playlistIndex),
              ),
            ],
          ),
          body: playlist.songs.isEmpty
              ? const Center(child: Text('No songs yet. Tap + to add.'))
              : ListView.builder(
                  itemCount: playlist.songs.length,
                  itemBuilder: (context, index) {
                    final song = playlist.songs[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: _songThumb(song),
                        ),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      onTap: () {
                        provider.playFromPlaylist(playlistIndex, index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SongPage()),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _songThumb(Song song) {
    if (song.album.isEmpty) {
      return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.music_note, size: 24));
    }
    if (song.isAsset) {
      return Image.asset(song.album, fit: BoxFit.cover);
    }
    final file = File(song.album);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.music_note, size: 24));
  }
}
