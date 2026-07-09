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
      title: 'Music Player',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
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
    'Electronic',
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎵 Disco giratorio con efecto de sombra
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anillo exterior con brillo
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.withOpacity(0.5),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Disco giratorio
                    RotationTransition(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Centro brillante
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white,
                            Colors.grey.shade400,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              // 🎵 Nombre de la canción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  songNames[currentIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 🎚 Slider mejorado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 8,
                        activeTrackColor: Colors.purple.shade400,
                        inactiveTrackColor: Colors.grey.shade800,
                        thumbColor: Colors.purpleAccent,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                          elevation: 5,
                        ),
                        overlayColor: Colors.purple.withOpacity(0.3),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 15,
                        ),
                      ),
                      child: Slider(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatTime(position),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            formatTime(duration),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // 🎮 Controles de reproducción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón anterior
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade700,
                            Colors.purple.shade500,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                        onPressed: prevMusic,
                      ),
                    ),
                    // Botón play/pause principal
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade300,
                            Colors.purple.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1, end: 1.1)
                            .animate(_controller),
                        child: IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            isPlaying ? pauseMusic() : playMusic();
                          },
                        ),
                      ),
                    ),
                    // Botón siguiente
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade700,
                            Colors.purple.shade500,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                        onPressed: nextMusic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
