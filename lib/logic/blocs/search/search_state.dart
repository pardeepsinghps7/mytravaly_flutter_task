// lib/logic/blocs/search/search_state.dart
import 'package:equatable/equatable.dart';
import '../../../data/models/hotel.dart';

abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}
class SearchLoading extends SearchState {}
class SearchLoaded extends SearchState {
  final List<Hotel> results;
  final int rid; // current offset used
  final bool hasMore;
  SearchLoaded({required this.results, required this.rid, required this.hasMore});
  @override
  List<Object?> get props => [results, rid, hasMore];
}
class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
  @override
  List<Object?> get props => [message];
}
