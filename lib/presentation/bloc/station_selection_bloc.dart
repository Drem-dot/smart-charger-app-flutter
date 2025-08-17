
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/station_entity.dart';

part 'station_selection_event.dart';
part 'station_selection_state.dart';

class StationSelectionBloc extends Bloc<StationSelectionEvent, StationSelectionState> {
  StationSelectionBloc() : super(NoStationSelected()) {
    on<StationSelected>((event, emit) {
      emit(StationSelectionSuccess(event.station));
    });
    
    on<StationDeselected>((event, emit) {
      emit(NoStationSelected());
    });
  }
}