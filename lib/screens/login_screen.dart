import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';
import 'clock_in_out_screen.dart';
import 'package:clock_in/services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';

  Future<void> _loginButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        AuthService authService = AuthService();
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Get UserData
        UserData? userData = await authService.getUserData(
            userCredential.user!.uid, userCredential.user!.email!);
        if (userData == null) {
          throw Exception('User data not found.');
        }

        if (!userData.isActive) {
          print('This user is not active.');
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClockInOutScreen(user: userData),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('No user found for that email')));
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Wrong password provided for this user')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    autocorrect: false,
                    enableSuggestions: false,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your email' : null,
                    onSaved: (value) => _email = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                    onSaved: (value) => _password = value!,
                  ),
                  ElevatedButton(
                    onPressed: _loginButtonPressed,
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
