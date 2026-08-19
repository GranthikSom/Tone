import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottombar.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/models/playlist_provider.dart';
import 'package:flutter_application_1/pages/playlist_detail_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tone"), elevation: 0),
      drawer: const MyDrawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          final playlists = provider.playlists;
          return Stack(
            children: [
              GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: playlists.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  if (index < playlists.length) {
                    return _playlistTile(context, provider, index);
                  }
                  return _addMusicTile(context, provider);
                },
              ),
              // Bottom-right action buttons
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _pill('Add Audio',
                        () => _showAddAudioPicker(context, provider)),
                    const SizedBox(height: 8),
                    _pill('Add Playlist',
                        () => _showNewPlaylistDialog(context, provider)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const Bottombar(),
    );
  }

  Widget _playlistTile(
      BuildContext context, PlaylistProvider provider, int index) {
    final playlist = provider.playlists[index];
    final hasCover =
        playlist.songs.isNotEmpty && playlist.songs.first.album.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PlaylistDetailPage(playlistIndex: index)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: hasCover
                  ? _buildCover(playlist.songs.first)
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                          child: Icon(Icons.music_note, size: 40)),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(playlist.name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCover(Song song) {
    if (song.isAsset) {
      return Image.asset(song.album,
          fit: BoxFit.cover, width: double.infinity);
    }
    if (song.album.isNotEmpty && File(song.album).existsSync()) {
      return Image.file(File(song.album),
          fit: BoxFit.cover, width: double.infinity);
    }
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.music_note, size: 40)),
    );
  }

  Widget _addMusicTile(BuildContext context, PlaylistProvider provider) {
    return GestureDetector(
      onTap: () => _showAddAudioPicker(context, provider),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[400],
                  ),
                  child: const Icon(Icons.add, size: 30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Add Music', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _pill(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[600],
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

  void _showNewPlaylistDialog(
      BuildContext context, PlaylistProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                provider.addPlaylist(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddAudioPicker(
      BuildContext context, PlaylistProvider provider) {
    final playlists = provider.playlists;
    if (playlists.isEmpty) {
      _showNewPlaylistDialog(context, provider);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add to playlist',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...List.generate(
              playlists.length,
              (i) => ListTile(
                title: Text(playlists[i].name),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickAndAddAudio(i);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
