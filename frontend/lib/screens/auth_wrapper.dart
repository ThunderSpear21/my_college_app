import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_state.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/title_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // This BlocBuilder is the single source of truth for navigation.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // If authenticated, show the HomeScreen.
          return const HomeScreen();
        }
        if (state is Unauthenticated) {
          // If unauthenticated, show the LoginScreen.
          return const LoginScreen();
        }
        // For AuthInitial or AuthLoading, show the splash screen.
        return const TitleScreen();
      },
    );
  }
}
