import 'package:flame/extensions.dart';
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

class Piece extends SpriteComponent {
  String spritePath;
  Vector2 position_;
  Vector2 size_;

  Piece({
    required this.spritePath,
    required this.position_,
    required this.size_,
  }) : super(
          anchor: Anchor.center,
          position: position_,
          size: size_,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(spritePath);
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
  List<Piece> redPlayerPieces = <Piece>[];
  List<Piece> bluePlayerPieces = <Piece>[];
  List<Piece> greenPlayerPieces = <Piece>[];
  List<Piece> yellowPlayerPieces = <Piece>[];

  LudoWorld() {
    // Initialiser diceBox avec une référence à this
    diceBox = TappableRectangle(
      ludoWorld: this,
      anchor: Anchor.center,
    );
    redPlayerPieces = <Piece>[
      Piece(
        spritePath: 'red_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'red_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'red_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'red_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
    ];
    greenPlayerPieces = <Piece>[
      Piece(
        spritePath: 'green_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'green_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'green_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'green_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
    ];
    bluePlayerPieces = <Piece>[
      Piece(
        spritePath: 'blue_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'blue_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'blue_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'blue_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
    ];
    yellowPlayerPieces = <Piece>[
      Piece(
        spritePath: 'yellow_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'yellow_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'yellow_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
      Piece(
        spritePath: 'yellow_piece.png',
        position_: Vector2(0, 0),
        size_: Vector2(20, 20),
      ),
    ];
  }

  @override
  Future<void> onLoad() async {
    await addAll(<Component>[
      board,
      diceBox,
      redPlayerPieces[0],
      redPlayerPieces[1],
      redPlayerPieces[2],
      redPlayerPieces[3],
      bluePlayerPieces[0],
      bluePlayerPieces[1],
      bluePlayerPieces[2],
      bluePlayerPieces[3],
      greenPlayerPieces[0],
      greenPlayerPieces[1],
      greenPlayerPieces[2],
      greenPlayerPieces[3],
      yellowPlayerPieces[0],
      yellowPlayerPieces[1],
      yellowPlayerPieces[2],
      yellowPlayerPieces[3],
    ]);
    await diceBox.add(diceText);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // set the positions of the dice boxes
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

    redPlayerPieces[0].position = Vector2(size.x / 4.55, -size.x / 3.2);
    redPlayerPieces[1].position = Vector2(size.x / 3.55, -size.x / 2.7);
    redPlayerPieces[2].position = Vector2(size.x / 2.9, -size.x / 3.2);
    redPlayerPieces[3].position = Vector2(size.x / 3.55, -size.x / 4);

    bluePlayerPieces[0].position = Vector2(size.x / 3.5, size.x / 5);
    bluePlayerPieces[1].position = Vector2(size.x / 2.9, size.x / 4);
    bluePlayerPieces[2].position = Vector2(size.x / 3.5, size.x / 3.2);
    bluePlayerPieces[3].position = Vector2(size.x / 4.5, size.x / 4);

    yellowPlayerPieces[0].position = Vector2(-size.x / 4.5, size.x / 4);
    yellowPlayerPieces[1].position = Vector2(-size.x / 3.5, size.x / 3.2);
    yellowPlayerPieces[2].position = Vector2(-size.x / 2.9, size.x / 4);
    yellowPlayerPieces[3].position = Vector2(-size.x / 3.5, size.x / 5);

    greenPlayerPieces[0].position = Vector2(-size.x / 4.5, -size.x / 3.3);
    greenPlayerPieces[1].position = Vector2(-size.x / 3.5, -size.x / 2.7);
    greenPlayerPieces[2].position = Vector2(-size.x / 2.9, -size.x / 3.3);
    greenPlayerPieces[3].position = Vector2(-size.x / 3.5, -size.x / 4.2);
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
