import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/playlist_provider.dart';
import 'package:flutter_application_1/pages/home_screen.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final playlistProvider = PlaylistProvider();
  await playlistProvider.init();

  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(playlistProvider),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.app.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider.value(value: playlistProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: Provider.of<ThemeProvider>(context).themeDate,
    );
  }
}
