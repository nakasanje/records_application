import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Ink(
      height: 200,
      width: 500,
      decoration: const BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.contain,
        image: AssetImage("assets/images/records.png"),
      )),
    );
  }
}
