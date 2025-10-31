
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthInProgress extends AuthState {}
class Authenticated extends AuthState {
  final String displayName;
  Authenticated(this.displayName);
  @override
  List<Object?> get props => [displayName];
}
class Unauthenticated extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
