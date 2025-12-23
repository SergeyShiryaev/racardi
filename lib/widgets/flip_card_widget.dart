import 'dart:math';
import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const FlipCard({super.key, required this.front, required this.back});

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  void flip() {
    _controller.isCompleted
        ? _controller.reverse()
        : _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final angle = _controller.value * pi;
          final isFront = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: isFront ? widget.front : widget.back,
          );
        },
      ),
    );
  }
}
