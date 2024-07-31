import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Tuple<A, B> {
  final A x;
  final B y;

  Tuple(this.x, this.y);
}

class PieceEffect {
  Vector2 targetPosition;

  PieceEffect(this.targetPosition);

  MoveEffect selectionEffect() {
    return MoveEffect.to(
      targetPosition,
      EffectController(
        duration: 1,
        reverseDuration: 1,
        infinite: true,
        curve: Curves.linear,
      ),
    );
  }
}
