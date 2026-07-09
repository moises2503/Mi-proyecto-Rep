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
      backgroundColor: Colors.black, //  Fondo negro
      body: Center(
        child: FadeTransition(
          // 🌫 Aparece/desaparece suavemente
          opacity: _fadeAnimation,
          child: RotationTransition(
            //  Rotación infinita
            turns: _controller,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  Logo de música
                Image.asset(
                  "assets/images/music.png",
                  width: 150,
                ),
                const SizedBox(height: 20), //  Espacio entre logo y loader
                // ⏳ Indicador de carga
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
