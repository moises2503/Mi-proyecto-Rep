import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_application_rep/home.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HOLA MUNDO',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: SplashScreen(),
    );
  }
}

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VideoPlayerController _videoController;

  int currentIndex = 0;
  bool isPlaying = false;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  final List<String> playlist = [
    'audio/cancion1.mp3',
    'audio/cancion2.mp3',
    'audio/cancion3.mp3',
    'audio/cancion4.mp3',
    'audio/cancion5.mp3',
  ];

  final List<String> songNames = [
    'Puto el que lo lea',
    'Sleep',
    'Contra-Whip',
    'Studio-lum',
    'Elevita',
  ];

  final String imagePath = 'assets/images/music.png';
  final String videoPath = 'assets/video/video1.mp4';

  late AnimationController _controller;
  Widget? videoBackground;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // VIDEO INIT (MEJORADO)
    _videoController = VideoPlayerController.asset(
      videoPath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();

        videoBackground = Positioned.fill(
          child: IgnorePointer(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),
          ),
        );

        setState(() {});
      });

    //  SIN setState (evita freeze del video)
    _audioPlayer.onDurationChanged.listen((d) {
      duration = d;
    });

    _audioPlayer.onPositionChanged.listen((p) {
      position = p;
    });
  }

  //  OPCION 2: FORZAR VIDEO SIEMPRE ACTIVO
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_videoController.value.isInitialized) {
      _videoController.play();
    }
  }

  void playMusic() async {
    await _audioPlayer.play(AssetSource(playlist[currentIndex]));
    _controller.repeat();
    setState(() => isPlaying = true);
  }

  void pauseMusic() async {
    await _audioPlayer.pause();
    _controller.stop();
    setState(() => isPlaying = false);
  }

  void nextMusic() async {
    currentIndex = (currentIndex + 1) % playlist.length;
    await _audioPlayer.stop();
    playMusic();
  }

  void prevMusic() async {
    currentIndex =
        (currentIndex - 1) < 0 ? playlist.length - 1 : currentIndex - 1;
    await _audioPlayer.stop();
    playMusic();
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds % 60);
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (videoBackground != null) videoBackground!,
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: RotationTransition(
                  turns: _controller,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Text(
                songNames[currentIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                thumbColor: Colors.white,
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds
                    .toDouble()
                    .clamp(0, duration.inSeconds.toDouble()),
                onChanged: (value) async {
                  final newPosition = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(newPosition);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      formatTime(duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        size: 40, color: Colors.white),
                    onPressed: prevMusic,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        isPlaying ? pauseMusic() : playMusic();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        size: 40, color: Colors.white),
                    onPressed: nextMusic,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
