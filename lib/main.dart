import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:ludo/ludo_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            // Obtenir la taille de l'écran
            final screenSize = MediaQuery.of(context).size;

            // Créer une instance de votre jeu
            final myGame = MyGame();

            // Utiliser la taille de l'écran pour initialiser le jeu si nécessaire
            myGame.onGameResize(Vector2(screenSize.width, screenSize.height));

            return GameWidget(game: myGame);
          },
        ),
      ),
    );
  }
}
