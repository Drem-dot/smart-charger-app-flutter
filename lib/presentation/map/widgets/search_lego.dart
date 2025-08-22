import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/repositories/geocoding_repository_impl.dart';
import '../../../domain/entities/geocoding_result_entity.dart';
import '../../../domain/repositories/i_geocoding_repository.dart';
import '../../bloc/map_control_bloc.dart';
import '../../bloc/route_bloc.dart';
import '../../bloc/search_bloc.dart';
import 'directions_lego.dart';

enum SearchMode { search, directions }

class SearchLego extends StatelessWidget {
  final Position? currentUserPosition;
  const SearchLego({super.key, this.currentUserPosition});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IGeocodingRepository>(
      create: (context) => GeocodingRepositoryImpl(),
      child: BlocProvider(
        create: (context) => SearchBloc(context.read<IGeocodingRepository>()),
        child: _SearchView(currentUserPosition: currentUserPosition),
      ),
    );
  }
}

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

  // State để "nhớ" kết quả tìm kiếm cuối cùng
  GeocodingResult? _lastSearchResult;

  // <-- THAY ĐỔI 1: Thêm initState để lắng nghe sự thay đổi của text controller
  @override
  void initState() {
    super.initState();
    // Thêm listener để gọi setState(), việc này sẽ build lại widget
    // và giúp cập nhật trạng thái hiển thị của nút "X"
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  // Giao diện cho chế độ Tìm kiếm
  Widget _buildSearchUI() {
    return Column(
      key: const ValueKey('search_mode'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm địa điểm...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  // <-- THAY ĐỔI 2: Áp dụng logic hiển thị có điều kiện cho suffixIcon
                  suffixIcon: _textController.text.isNotEmpty // Chỉ hiển thị khi có text
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _textController.clear();
                            context.read<SearchBloc>().add(const SearchQueryChanged(''));
                            setState(() => _lastSearchResult = null); // Xóa bộ nhớ
                          },
                        )
                      : null, // Ẩn đi khi không có text
                ),
                onChanged: (query) => context.read<SearchBloc>().add(SearchQueryChanged(query)),
              ),
            ),
            // Nút "Tìm đường"
            IconButton(
              icon: const Icon(Icons.directions),
              tooltip: 'Tìm đường',
              onPressed: () {
                // Nếu có kết quả tìm kiếm cuối cùng, sử dụng nó
                if (_lastSearchResult != null) {
                  context.read<RouteBloc>().add(DestinationUpdated(
                    position: _lastSearchResult!.latLng,
                    name: _lastSearchResult!.name,
                  ));
                }
                // Chuyển sang chế độ tìm đường
                setState(() => _mode = SearchMode.directions);
                _focusNode.unfocus();
                _textController.clear();
                context.read<SearchBloc>().add(const SearchQueryChanged(''));
              },
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
                      onTap: () {
                        // "Nhớ" kết quả
                        setState(() => _lastSearchResult = result);
                        // Di chuyển camera
                        context.read<MapControlBloc>().add(CameraMoveRequested(result.latLng, 16.0));
                        // Ẩn danh sách gợi ý
                        _focusNode.unfocus();
                        context.read<SearchBloc>().add(const SearchQueryChanged(''));
                      },
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

  // Giao diện cho chế độ Tìm đường
  Widget _buildDirectionsUI() {
    return Column(
      key: const ValueKey('directions_mode'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('Tìm đường', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

   @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _mode == SearchMode.search
            ? _buildSearchUI()
            : _buildDirectionsUI(),
      ),
    );
  }
}