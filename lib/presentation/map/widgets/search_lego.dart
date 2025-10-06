import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_charger_app/domain/entities/geocoding_result_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_geocoding_repository.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/nearby_stations_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/search_bloc.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';
import 'package:smart_charger_app/presentation/map/widgets/directions_lego.dart';

enum SearchMode { search, directions }

/// Widget Cha: Chịu trách nhiệm cung cấp SearchBloc
class SearchLego extends StatelessWidget {
  final Position? currentUserPosition;
  const SearchLego({super.key, this.currentUserPosition});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(context.read<IGeocodingRepository>()),
      child: _SearchView(currentUserPosition: currentUserPosition),
    );
  }
}

/// Widget Trung gian: Quản lý trạng thái chung (SearchMode)
class _SearchView extends StatefulWidget {
  final Position? currentUserPosition;
  const _SearchView({this.currentUserPosition});

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  SearchMode _mode = SearchMode.search;
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  GeocodingResult? _lastSearchResult;

  @override
  void initState() {
    super.initState();
    // Listener chỉ để cập nhật nút X, không cần thiết cho logic chính
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias, // Giúp bo góc hoạt động tốt hơn
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _mode == SearchMode.search
            ? _SearchInputAndResults(
                key: const ValueKey('search_ui'),
                textController: _textController,
                focusNode: _focusNode,
                onResultSelected: (result) {
                  setState(() => _lastSearchResult = result);
                  _focusNode.unfocus();
                  // Các BLoC này được đọc từ context của _SearchViewState, vốn nằm dưới MapPage, nên an toàn
                  context.read<MapControlBloc>().add(CameraMoveRequested(result.latLng, 16.0));
                  // 2. (THÊM MỚI) Yêu cầu NearbyStationsBloc cập nhật dữ liệu
                  // Dùng event FetchStationsAroundPoint đã có sẵn
                  context.read<NearbyStationsBloc>().add(FetchStationsAroundPoint(result.latLng));
                  context.read<SearchBloc>().add(const SearchQueryChanged(''));
                },
                onSwitchToDirections: () {
                  if (_lastSearchResult != null) {
                    context.read<RouteBloc>().add(DestinationUpdated(
                      position: _lastSearchResult!.latLng,
                      name: _lastSearchResult!.name,
                    ));
                  }
                  setState(() => _mode = SearchMode.directions);
                  _focusNode.unfocus();
                  _textController.clear();
                  context.read<SearchBloc>().add(const SearchQueryChanged(''));
                },
              )
            : _buildDirectionsUI(),
      ),
    );
  }

  Widget _buildDirectionsUI() {
    return Column(
      key: const ValueKey('directions_ui'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(AppLocalizations.of(context)!.directionsTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _mode = SearchMode.search);
                context.read<RouteBloc>().add(RouteCleared());
              },
            ),
          ],
        ),
        const Divider(height: 1),
        DirectionsLego(currentUserPosition: widget.currentUserPosition),
      ],
    );
  }
}

/// WIDGET CON MỚI: Chịu trách nhiệm cho việc nhập liệu và hiển thị kết quả
class _SearchInputAndResults extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final ValueChanged<GeocodingResult> onResultSelected;
  final VoidCallback onSwitchToDirections;

  const _SearchInputAndResults({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onResultSelected,
    required this.onSwitchToDirections,
  });

  @override
  Widget build(BuildContext context) {
    // `context` ở đây chắc chắn nằm dưới BlocProvider<SearchBloc>
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: textController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            textController.clear();
                            context.read<SearchBloc>().add(const SearchQueryChanged(''));
                          },
                        )
                      : null,
                ),
                // `context` ở đây là của _SearchInputAndResults, nên nó an toàn
                onChanged: (query) => context.read<SearchBloc>().add(SearchQueryChanged(query)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.directions),
              tooltip: AppLocalizations.of(context)!.directionsTooltip,
              onPressed: onSwitchToDirections,
            ),
          ],
        ),
        BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) return const LinearProgressIndicator();
            if (state is SearchSuccess && state.results.isNotEmpty) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = state.results[index];
                    return ListTile(
                      title: Text(result.name),
                      subtitle: Text(result.address),
                      onTap: () => onResultSelected(result),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}