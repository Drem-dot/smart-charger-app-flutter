part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final String sessionToken;
  const SearchQueryChanged(this.query, {required this.sessionToken});

  @override
  List<Object> get props => [query];
}