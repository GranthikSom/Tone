import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottombar.dart';
import 'package:flutter_application_1/components/my_drawer.dart';
import 'package:flutter_application_1/models/playlist_provider.dart';
import 'package:flutter_application_1/pages/song_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tone"), elevation: 0),
      drawer: MyDrawer(),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          final songs = playlistProvider.playlists;

          return GridView.builder(
            itemCount: songs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final song = songs[index];
              return GestureDetector(
                onTap: () {
                  playlistProvider.currentSongIndex = index;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SongPage()),
                  );
                },
                child: Card(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Image.asset(song.album, height: 120, fit: BoxFit.cover),
                      Text(song.title),
                      Text(song.artist),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          playlistProvider.currentSongIndex = index;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SongPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const Bottombar(),
    );
  }
}
