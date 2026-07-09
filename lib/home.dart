import 'package:flutter/material.dart'; //  Librería principal de Flutter para UI
import 'package:flutter_application_rep/main.dart'; //  Importa la página principal (MusicPlayerPage)
import 'dart:async'; //  Para manejar temporizadores y delays

//  Pantalla de inicio (SplashScreen)
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

//  Estado del SplashScreen con animaciones
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // 🎛 Controlador de animaciones
  late Animation<double> _fadeAnimation; // 🌫 Animación de opacidad (fade)

  @override
  void initState() {
    super.initState();

    //  Configuración de la animación
    _controller = AnimationController(
      vsync: this, // Necesario para sincronizar con el ciclo de vida
      duration: const Duration(seconds: 2), //  Duración de la animación
    );

    // 🌫 Animación de opacidad: de invisible (0) a visible (1)
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.repeat(); //  Hace que la animación se repita infinitamente

    // ⏳ Delay de 3 segundos antes de navegar a la pantalla principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MusicPlayerPage(), //  Página principal
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); //  Libera recursos del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.black,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0)
                      .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
                  child: RotationTransition(
                    turns: _controller,
                    child: Container(
                      width: 200,
                      height: 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.shade300,
                            Colors.purple.shade700,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.8),
                            blurRadius: 40,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: AssetImage("assets/images/music.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  'Music Player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.purple.withOpacity(0.8),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RotationTransition(
                        turns: _controller,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.purple.shade400,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _controller,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.6),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.purpleAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purpleAccent.withOpacity(0.8),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'Cargando',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
