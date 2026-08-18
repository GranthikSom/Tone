import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  late PageController _pageController;
  int _lastKnownIndex = -1;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PlaylistProvider>(context, listen: false);
    _lastKnownIndex = provider.currentSongIndex ?? 0;
    _pageController = PageController(initialPage: _lastKnownIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final playlist = value.playlists;
        final songIndex = playlist[value.currentSongIndex ?? 0];
        
        if (_lastKnownIndex != (value.currentSongIndex ?? 0)) {
           _lastKnownIndex = value.currentSongIndex ?? 0;
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (_pageController.hasClients && _pageController.page?.round() != _lastKnownIndex) {
                _pageController.animateToPage(
                  _lastKnownIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
             }
           });
        }
        
        int prevIndex = (value.currentSongIndex ?? 0) - 1;
        if (prevIndex < 0) prevIndex = playlist.length - 1;
        int nextIndex = (value.currentSongIndex ?? 0) + 1;
        if (nextIndex >= playlist.length) nextIndex = 0;
        
        final prevSong = playlist[prevIndex];
        final nextSong = playlist[nextIndex];

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image(image: AssetImage(songIndex.album), fit: BoxFit.cover),
              // Blur Layer
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.white.withOpacity(0.4)),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          const Text("Now Playing", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text("Hi-res", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Album Art PageView
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: playlist.length,
                          onPageChanged: (index) {
                            if (value.currentSongIndex != index) {
                              value.currentSongIndex = index;
                            }
                          },
                          itemBuilder: (context, index) {
                            final pageSong = playlist[index];
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Image(image: AssetImage(pageSong.album), fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Title & Artist
                      Text(
                        songIndex.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        songIndex.artist.toUpperCase(),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.black.withOpacity(0.1), thickness: 1.5),
                      const SizedBox(height: 10),
                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.black.withOpacity(0.2),
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: value.currentDuration.inSeconds.toDouble(),
                          min: 0,
                          max: value.totalDuration.inSeconds > 0 ? value.totalDuration.inSeconds.toDouble() : 1,
                          onChanged: (double val) {
                            value.seek(Duration(seconds: val.toInt()));
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bottom Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('from "hits"', style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14)),
                              Text('previous ${prevSong.title.toUpperCase()}', style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14)),
                              Text('next ${nextSong.title.toUpperCase()}', style: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14)),
                            ],
                          ),
                          GestureDetector(
                            onTap: value.pauseOrResume,
                            child: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black.withOpacity(0.8),
                              size: 70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
