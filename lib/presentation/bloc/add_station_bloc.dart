import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/i_station_repository.dart';
import '../../domain/utils/chunk_calculator.dart';

part 'add_station_event.dart';
part 'add_station_state.dart';

class AddStationBloc extends Bloc<AddStationEvent, AddStationState> {
  final IStationRepository _stationRepository;

  AddStationBloc(this._stationRepository) : super(AddStationInitial()) {
    on<PositionSelected>((event, emit) {
      emit(AddStationPositionConfirmed(event.position));
    });

    on<FormSubmitted>(_onFormSubmitted);

    on<AddStationReset>((event, emit) {
      emit(AddStationInitial());
    });
  }

  Future<void> _onFormSubmitted(FormSubmitted event, Emitter<AddStationState> emit,) async {
      // Logic giờ đơn giản hơn, không cần đọc state
      emit(AddStationInProgress(event.position));
      try {
        final chunkId = ChunkCalculator.calculateChunkId(event.position);
        final fullStationData = {
          ...event.formData,
          'chunkId': chunkId,
          'location': {
            'type': 'Point',
            'coordinates': [event.position.longitude, event.position.latitude],
          }
        };
        final newStation = await _stationRepository.createStation(fullStationData);
        emit(AddStationSuccess(newStation));
      } catch (e) {
        emit(AddStationFailure(e.toString(), event.position));
      }
  }
}