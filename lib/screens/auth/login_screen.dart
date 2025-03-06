import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  InputDecoration inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey,
      border: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("login"),
            TextField(
              decoration: inputDecoration(),
            )
          ],
        ),
      ),
    );
  }
}
