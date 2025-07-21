import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/theme/theme_event.dart';
import 'package:frontend/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.light)) {
    on<ThemeToggled>((event, emit) {
      // When the toggle event is received, switch the state
      if (state.themeMode == ThemeMode.light) {
        emit(const ThemeState(ThemeMode.dark));
      } else {
        emit(const ThemeState(ThemeMode.light));
      }
    });
  }
}