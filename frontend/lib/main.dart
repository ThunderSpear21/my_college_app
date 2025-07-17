import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/login/login_bloc.dart';
import 'package:frontend/blocs/register/register_bloc.dart';
import 'package:frontend/blocs/verify_email/verify_email_bloc.dart';
import 'package:frontend/screens/title_screen.dart';
import 'package:frontend/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => VerifyEmailBloc()),
        BlocProvider(create: (_) => RegisterBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'my-college-app',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const TitleScreen(),
      ),
    );
  }
}
