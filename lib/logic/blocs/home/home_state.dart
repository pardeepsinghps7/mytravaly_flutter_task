import 'package:equatable/equatable.dart';
import '../../../data/models/hotel.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Hotel> hotels;
  HomeLoaded(this.hotels);

  @override
  List<Object?> get props => [hotels];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
