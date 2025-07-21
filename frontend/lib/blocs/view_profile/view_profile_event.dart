import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ViewProfileEvent extends Equatable {
  const ViewProfileEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched to load the initial user profile data.
class ProfileLoadRequested extends ViewProfileEvent {}

/// Event dispatched when the user submits the form to update their name.
class ProfileUpdateSubmitted extends ViewProfileEvent {
  final String newName;

  const ProfileUpdateSubmitted({required this.newName});

  @override
  List<Object> get props => [newName];
}