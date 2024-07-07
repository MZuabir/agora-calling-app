
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaveLoadingWidget extends StatefulWidget {
  const WaveLoadingWidget(
      {super.key, this.color = Colors.blue, this.size = 35});
  final Color color;
  final double size;
  @override
  State<WaveLoadingWidget> createState() => _WaveLoadingWidgetState();
}

class _WaveLoadingWidgetState extends State<WaveLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController animationController;
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: widget.color,
      size: widget.size,
      controller: animationController,
    );
  }
}
