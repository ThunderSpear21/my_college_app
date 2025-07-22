import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedOut extends AuthEvent {}

class LoggedIn extends AuthEvent {}

class UserUpdated extends AuthEvent {
  final Map<String, dynamic> updatedUser;

  const UserUpdated(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}