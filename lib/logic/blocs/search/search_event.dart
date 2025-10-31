// lib/logic/blocs/search/search_event.dart
import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchStarted extends SearchEvent {
  final String query;
  final String type;
  SearchStarted(this.query, this.type);
  @override
  List<Object?> get props => [query,type];
}

class SearchLoadMore extends SearchEvent {}
