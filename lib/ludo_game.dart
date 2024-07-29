import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class TappableRectangle extends RectangleComponent with TapCallbacks {
  final LudoWorld ludoWorld; // Référence à LudoWorld

  TappableRectangle({
    required this.ludoWorld,
    required Anchor anchor,
  }) : super(
          anchor: anchor,
        );

  @override
  void onTapUp(TapUpEvent event) {
    // Appeler la méthode de LudoWorld lorsque le rectangle est tapé
    ludoWorld.rollDice();
  }
}

class MyBoard extends SpriteComponent {
  MyBoard()
      : super(
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('board.png');
  }
}

class LudoWorld extends World {
  late final MyBoard board = MyBoard();
  late final TappableRectangle diceBox;
  final int possibleDiceValues = 6;
  int whoPlays = 1;
  var diceText = TextComponent(
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 50,
      ),
    ),
    position: Vector2(10, 0),
  );
  final double diceBoxSize = 50.0;
  final Random random = Random();
  final List<Vector2> diceBoxPositions = <Vector2>[];

  LudoWorld() {
    // Initialiser diceBox avec une référence à this
    diceBox = TappableRectangle(
      ludoWorld: this,
      anchor: Anchor.center,
    );
  }

  @override
  Future<void> onLoad() async {
    await addAll(<Component>[
      board,
      diceBox,
    ]);
    await diceBox.add(diceText);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    diceBoxPositions
        .add(Vector2(-size.x / 2 + diceBoxSize / 2 + 20, -size.x / 2 - 20));
    diceBoxPositions
        .add(Vector2(size.x / 2 - diceBoxSize / 2 - 20, -size.x / 2 - 20));
    diceBoxPositions
        .add(Vector2(size.x / 2 - diceBoxSize / 2 - 20, size.x / 2 + 20));
    diceBoxPositions
        .add(Vector2(-size.x / 2 + diceBoxSize / 2 + 20, size.x / 2 + 20));

    board.size = Vector2(size.x, size.x);
    board.position = Vector2(0, 0);

    diceBox.size = Vector2(diceBoxSize, diceBoxSize);
    diceBox.position = diceBoxPositions[whoPlays - 1];
  }

  void rollDice() {
    diceText.text = (random.nextInt(possibleDiceValues) + 1).toString();
    changePlayer();
  }

  void changePlayer() {
    whoPlays++;
    if (whoPlays == 5) {
      whoPlays = 1;
    }
    diceBox.position = diceBoxPositions[whoPlays - 1];
  }
}

class MyGame extends FlameGame {
  MyGame() : super(world: LudoWorld());

  @override
  Color backgroundColor() => const Color.fromARGB(255, 0, 132, 240);
}
