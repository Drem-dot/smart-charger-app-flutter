import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/entities/geocoding_result_entity.dart';
import '../../domain/repositories/i_geocoding_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final IGeocodingRepository _geocodingRepository;

  SearchBloc(this._geocodingRepository) : super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    try {
   

      final suggestions = await _geocodingRepository.getAutocompleteSuggestions(
        event.query, 
        sessionToken: event.sessionToken
      );

      final List<GeocodingResult> results = [];
      for (var suggestion in suggestions) {
        final latLng = await _geocodingRepository.getLatLngFromPlaceId(
          suggestion.placeId, 
          sessionToken: event.sessionToken
        );
        if (latLng != null) {
          results.add(GeocodingResult(
            name: suggestion.description.split(',')[0],
            address: suggestion.description,
            latLng: latLng
          ));
        }
      }

      emit(SearchSuccess(results));

    } catch (e) {
      emit(SearchFailure(e.toString()));
    }
  }
}