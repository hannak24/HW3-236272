import 'package:flutter/material.dart';
import 'package:hello_me/autentication_notifier.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          return user == null? LoginScreen() : HomeScreen();
        }
        else{
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator()
            )
          );
        }
      }
    );
  }
}
