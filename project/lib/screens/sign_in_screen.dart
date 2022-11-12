import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:project/data/example_data.dart';
import 'package:project/models/project.dart';
import 'package:project/models/user.dart' as app;
import 'package:project/screens/create_profile_screen.dart';
import 'package:project/screens/home_screen.dart';
import 'package:project/styles/theme.dart';
import 'package:project/widgets/input_field.dart';

/// Screen/Scaffold for signing in and signing up .
class SignInScreen extends StatelessWidget {
  /// Named route for this screen.
  static const routeName = "/";

  /// Creates an instance of [SignInScreen].
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 70.0, 32.0, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height / 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text(
                      "solve",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "it",
                      style: TextStyle(
                        fontSize: 40,
                        color: Themes.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const _SignInForm(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sign in and sign up form.
class _SignInForm extends StatefulWidget {
  /// Creates an instance of [SignInForm].
  const _SignInForm({super.key});

  @override
  State<_SignInForm> createState() => __SignInFormState();
}

class __SignInFormState extends State<_SignInForm> {
  List<Project> projects = ExampleData.projects;
  app.User user = ExampleData.user2;
  bool signupForm = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          signupForm ? "sign up" : "login",
          style: const TextStyle(
            fontSize: 20,
            color: Themes.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        const InputField(
          label: "email",
          placeholderText: "email@example.com",
          keyboardAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
        ),
        signupForm
            ? Column(
                children: const <Widget>[
                  SizedBox(height: 6),
                  InputField(
                    label: "name",
                    placeholderText: "john doe",
                    isPassword: true,
                    keyboardAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              )
            : const SizedBox(),
        const SizedBox(height: 6),
        const InputField(
          label: "password",
          placeholderText: "password",
          isPassword: true,
          keyboardAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
        ),
        signupForm
            ? Column(
                children: const <Widget>[
                  SizedBox(height: 6),
                  InputField(
                    label: "confirm password",
                    placeholderText: "confirm password",
                    isPassword: true,
                    keyboardAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              )
            : const SizedBox(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: signupForm
              ? () =>
                  Navigator.of(context).pushNamed(CreateProfileScreen.routeName)
              : () => Navigator.of(context).popAndPushNamed(
                    HomeScreen.routeName,
                    arguments: {
                      "user": user,
                      "projects": projects,
                    },
                  ),
          style: Themes.primaryElevatedButtonStyle,
          child: Text(signupForm ? "sign up" : "sign in"),
        ),
        const SizedBox(height: 48),
        signupForm
            ? const Text(
                "or sign up with",
                textAlign: TextAlign.center,
              )
            : const Text(
                "or sign in with",
                textAlign: TextAlign.center,
              ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: _signInAnonymously,
              style: Themes.circularButtonStyle,
              child: const Icon(
                PhosphorIcons.facebookLogo,
                size: 36,
              ),
            ),
            ElevatedButton(
              onPressed: signupForm
                  ? () => Navigator.of(context)
                      .pushNamed(CreateProfileScreen.routeName)
                  : () => Navigator.of(context).popAndPushNamed(
                        HomeScreen.routeName,
                        arguments: {
                          "user": user,
                          "projects": projects,
                        },
                      ),
              style: Themes.circularButtonStyle,
              child: const Icon(
                PhosphorIcons.googleLogo,
                size: 36,
              ),
            ),
            ElevatedButton(
              onPressed: signupForm
                  ? () => Navigator.of(context)
                      .pushNamed(CreateProfileScreen.routeName)
                  : () => Navigator.of(context).popAndPushNamed(
                        HomeScreen.routeName,
                        arguments: {
                          "user": user,
                          "projects": projects,
                        },
                      ),
              style: Themes.circularButtonStyle,
              child: const Icon(
                PhosphorIcons.appleLogo,
                size: 36,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: signupForm
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("already have an account?"),
                    TextButton(
                      style: Themes.textButtonStyle,
                      child: const Text("sign in here >"),
                      onPressed: () => setState(() => signupForm = false),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("don't have an account?"),
                    TextButton(
                      style: Themes.textButtonStyle,
                      child: const Text("sign up here >"),
                      onPressed: () => setState(() => signupForm = true),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _signInAnonymously() async {
    try {
      final userCredentials = await FirebaseAuth.instance.signInAnonymously();
      if (kDebugMode) {
        print("${userCredentials.user?.uid}");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
