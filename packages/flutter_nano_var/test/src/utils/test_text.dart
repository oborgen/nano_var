import 'package:flutter/material.dart';

class TestText extends StatelessWidget {
  final data;

  const TestText(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(data),
    );
  }
}
