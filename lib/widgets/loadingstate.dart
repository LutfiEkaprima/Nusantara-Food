import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingState extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingState({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: LoadingAnimationWidget.flickr(
                rightDotColor: Colors.pink,
                leftDotColor: Colors.blue,
                size: 50,
              ),
            ),
          ),
      ],
    );
  }
}
