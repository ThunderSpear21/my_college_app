import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/admin/admin_bloc.dart';
import 'package:frontend/blocs/auth/auth_bloc.dart';
import 'package:frontend/blocs/auth/auth_event.dart';
import 'package:frontend/blocs/connect/connect_bloc.dart';
import 'package:frontend/blocs/course/course_bloc.dart';
import 'package:frontend/blocs/login/login_bloc.dart';
import 'package:frontend/blocs/notes/notes_bloc.dart';
import 'package:frontend/blocs/register/register_bloc.dart';
import 'package:frontend/blocs/theme/theme_bloc.dart';
import 'package:frontend/blocs/theme/theme_state.dart';
import 'package:frontend/blocs/verify_email/verify_email_bloc.dart';
import 'package:frontend/blocs/view_profile/view_profile_bloc.dart';
import 'package:frontend/screens/auth_wrapper.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthBloc authBloc = AuthBloc()..add(AppStarted());
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (context) => ViewProfileBloc(authBloc: authBloc)),
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => VerifyEmailBloc()),
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => CourseBloc()),
        BlocProvider(create: (_) => NoteBloc()),
        BlocProvider(create: (_) => ConnectBloc()),
        BlocProvider(create: (_) => AdminBloc(authBloc: authBloc)),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'my-college-app',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
