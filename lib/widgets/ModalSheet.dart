import 'package:flutter/material.dart';

class ModelSheetContent extends StatelessWidget {
  final Widget content;

  const ModelSheetContent({this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
