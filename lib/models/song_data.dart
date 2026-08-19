class Song {
  final String title;
  final String artist;
  final String album;
  final String audiopath;
  final String quote;
  final bool isAsset;

  Song({
    required this.title,
    required this.artist,
    required this.album,
    required this.audiopath,
    this.quote = '',
    this.isAsset = true,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'artist': artist,
        'album': album,
        'audiopath': audiopath,
        'quote': quote,
        'isAsset': isAsset,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        album: json['album'] ?? '',
        audiopath: json['audiopath'] ?? '',
        quote: json['quote'] ?? '',
        isAsset: json['isAsset'] ?? true,
      );
}

class Playlist {
  String name;
  final List<Song> songs;

  Playlist({required this.name, List<Song>? songs}) : songs = songs ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'songs': songs.map((s) => s.toJson()).toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        name: json['name'] ?? '',
        songs: (json['songs'] as List?)
                ?.map((s) => Song.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
