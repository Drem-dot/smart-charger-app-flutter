import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'point_selection_event.dart';
part 'point_selection_state.dart';

class PointSelectionBloc extends Bloc<PointSelectionEvent, PointSelectionState> {
  PointSelectionBloc() : super(PointSelectionInitial()) {
    on<SelectionStarted>((event, emit) {
      emit(PointSelectionInProgress(event.type));
    });

    on<SelectionFinalized>((event, emit) {
      emit(PointSelectionInitial());
    });
  }
}