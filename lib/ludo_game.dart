import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:ludo/costum.dart';

class TappableRectangle extends RectangleComponent with TapCallbacks {
  final LudoWorld ludoWorld;
  Color color;

  TappableRectangle({
    required this.ludoWorld,
    required Anchor anchor,
    required this.color,
  }) : super(
          anchor: anchor,
          paint: Paint()..color = color,
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

class Piece extends SpriteComponent with TapCallbacks {
  String spritePath;
  final LudoWorld ludoWorld;

  Piece({
    required this.ludoWorld,
    required this.spritePath,
  }) : super(
          anchor: Anchor.center,
        );

  @override
  void onTapUp(TapUpEvent event) {
    // Appeler la méthode de LudoWorld lorsque le rectangle est tapé
    ludoWorld.movePiece(this);
  }

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
  Map<int, List<Piece>> playersMap = {
    1: <Piece>[],
    2: <Piece>[],
    3: <Piece>[],
    4: <Piece>[],
  };
  List<Tuple<double, double>> scale = <Tuple<double, double>>[
    Tuple(4.55, 3.5),
    Tuple(3.55, 2.9),
    Tuple(2.9, 3.5),
    Tuple(3.55, 4.5),
  ];
  Tuple<double, double> piecesScale = Tuple(20, 20);
  MoveEffect selectedPieceEffect = PieceEffect(Vector2(0, 0)).selectionEffect();
  int turn = 1;
  bool isFirstMoveDone = false;
  int rollCont = 0;
  bool passToNextPlayer = false;
  Color diceFreeColor = const Color.fromARGB(255, 165, 248, 171);
  Color diceNotFreeColor = Color.fromARGB(255, 221, 114, 14);
  List<int> currentResults = <int>[];
  bool isFirstSix = false;
  int rollResult = 0;
  bool canPlay = true;

  LudoWorld() {
    // Initialiser diceBox avec une référence à this
    diceBox = TappableRectangle(
      ludoWorld: this,
      anchor: Anchor.center,
      color: diceFreeColor,
    );
    playersMap[1] = <Piece>[
      Piece(spritePath: 'red_piece.png', ludoWorld: this),
      Piece(spritePath: 'red_piece.png', ludoWorld: this),
      Piece(spritePath: 'red_piece.png', ludoWorld: this),
      Piece(spritePath: 'red_piece.png', ludoWorld: this),
    ];
    playersMap[2] = <Piece>[
      Piece(spritePath: 'blue_piece.png', ludoWorld: this),
      Piece(spritePath: 'blue_piece.png', ludoWorld: this),
      Piece(spritePath: 'blue_piece.png', ludoWorld: this),
      Piece(spritePath: 'blue_piece.png', ludoWorld: this),
    ];
    playersMap[3] = <Piece>[
      Piece(spritePath: 'yellow_piece.png', ludoWorld: this),
      Piece(spritePath: 'yellow_piece.png', ludoWorld: this),
      Piece(spritePath: 'yellow_piece.png', ludoWorld: this),
      Piece(spritePath: 'yellow_piece.png', ludoWorld: this),
    ];
    playersMap[4] = <Piece>[
      Piece(spritePath: 'green_piece.png', ludoWorld: this),
      Piece(spritePath: 'green_piece.png', ludoWorld: this),
      Piece(spritePath: 'green_piece.png', ludoWorld: this),
      Piece(spritePath: 'green_piece.png', ludoWorld: this),
    ];
  }

  @override
  Future<void> onLoad() async {
    await addAll(<Component>[
      board,
      diceBox,
    ]);
    await diceBox.add(diceText);
    await addAll(playersMap[1] as Iterable<Component>);
    await addAll(playersMap[2] as Iterable<Component>);
    await addAll(playersMap[3] as Iterable<Component>);
    await addAll(playersMap[4] as Iterable<Component>);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // set the positions of the dice boxes
    diceBoxPositions
        .add(Vector2(size.x / 2 - diceBoxSize / 2 - 20, -size.x / 2 - 20));
    diceBoxPositions
        .add(Vector2(size.x / 2 - diceBoxSize / 2 - 20, size.x / 2 + 20));
    diceBoxPositions
        .add(Vector2(-size.x / 2 + diceBoxSize / 2 + 20, size.x / 2 + 20));
    diceBoxPositions
        .add(Vector2(-size.x / 2 + diceBoxSize / 2 + 20, -size.x / 2 - 20));

    board.size = Vector2(size.x, size.x);
    board.position = Vector2(0, 0);

    diceBox.size = Vector2(diceBoxSize, diceBoxSize);
    diceBox.position = diceBoxPositions[whoPlays - 1];

    for (var i = 0; i < 4; i++) {
      playersMap[1]![i].size =
          Vector2(size.x / piecesScale.x, size.x / piecesScale.y);
      playersMap[1]![i].position = Vector2(
        size.x / scale[i].x,
        -size.x / scale[i].y,
      );
      playersMap[2]![i].size =
          Vector2(size.x / piecesScale.x, size.x / piecesScale.y);
      playersMap[2]![i].position = Vector2(
        size.x / scale[i].x,
        size.x / scale[i].y,
      );
      playersMap[3]![i].size =
          Vector2(size.x / piecesScale.x, size.x / piecesScale.y);
      playersMap[3]![i].position = Vector2(
        -size.x / scale[i].x,
        size.x / scale[i].y,
      );
      playersMap[4]![i].size =
          Vector2(size.x / piecesScale.x, size.x / piecesScale.y);
      playersMap[4]![i].position = Vector2(
        -size.x / scale[i].x,
        -size.x / scale[i].y,
      );
    }
  }

  void animatePiece(Piece piece, Vector2 position) {
    selectedPieceEffect = PieceEffect(
      Vector2(piece.position[0], piece.position[1] - 10),
    ).selectionEffect();
    piece.add(
      selectedPieceEffect,
    );
  }

  void rollDice() {
    if (canPlay) {
      if (passToNextPlayer) {
        changePlayer();
        diceBox.paint = Paint()..color = diceFreeColor;
        passToNextPlayer = false;
        rollCont = 0;
      } else {
        rollResult = simulateRollAnimation();
        diceText.text = (rollResult).toString();

        if (isFirstMoveDone) {
          enterTheMainRules(rollResult);
        } else {
          if (rollCont == 1 && rollResult != 6) {
            passToNextPlayer = true;
            diceBox.paint = Paint()..color = diceNotFreeColor;
          } else {
            if (rollResult == 6) {
              enterTheMainRules(rollResult);
              isFirstMoveDone = true;
            } else {
              rollCont++;
            }
          }
        }
      }
    }
  }

  void changePlayer() {
    whoPlays++;
    if (whoPlays == 5) {
      whoPlays = 1;
    }
    diceBox.position = diceBoxPositions[whoPlays - 1];
  }

  void movePiece(Piece piece) {}

  int simulateRollAnimation() {
    for (var i = 0; i < 10; i++) {
      diceText.text = (random.nextInt(possibleDiceValues) + 1).toString();
    }
    return random.nextInt(possibleDiceValues) + 1;
  }

  void enterTheMainRules(int rollResult) {
    if (rollResult == 6) {
      isFirstSix = true;
    } else {
      canPlay = false;
      countForCurrentPlayer();
      passToNextPlayer = true;
      diceBox.paint = Paint()..color = diceNotFreeColor;
      isFirstSix = false;
    }
    currentResults.add(rollResult);
  }

  void countForCurrentPlayer() {
    for (var piece in playersMap[whoPlays]!) {
      if (isPieceCanPlay(piece)) {
        animatePiece(piece, piece.position);
      }
    }
    canPlay = true;
  }

  bool isPieceCanPlay(Piece piece) {
    return true;
  }
}

class MyGame extends FlameGame {
  MyGame() : super(world: LudoWorld());

  @override
  Color backgroundColor() => const Color.fromARGB(255, 0, 132, 240);
}
