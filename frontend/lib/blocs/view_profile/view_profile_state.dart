import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ProfileStatus { initial, loading, success, failure, updating }

@immutable
class ViewProfileState extends Equatable {
  const ViewProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
  });

  final ProfileStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  // copyWith method to easily create new state instances
  ViewProfileState copyWith({
    ProfileStatus? status,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return ViewProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}