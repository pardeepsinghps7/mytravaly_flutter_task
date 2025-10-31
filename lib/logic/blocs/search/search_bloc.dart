import 'package:bloc/bloc.dart';
import 'search_event.dart';
import 'search_state.dart';
import '../../../data/models/hotel.dart';
import '../../../data/services/api_service.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiService _apiService;
  final int _pageSize;

  String _query = '';
  String _searchType = '';
  bool _hasMore = true;
  bool _isLoading = false;

  SearchBloc({ApiService? apiService, int pageSize = 5})
      : _apiService = apiService ?? ApiService(),
        _pageSize = pageSize,
        super(SearchInitial()) {
    on<SearchStarted>(_onSearchStarted);
    on<SearchLoadMore>(_onSearchLoadMore);
  }

  Future<void> _onSearchStarted(SearchStarted event, Emitter<SearchState> emit) async {
    _query = event.query;
    _searchType = event.type;
    _hasMore = true;
    emit(SearchLoading());
    try {
      _isLoading = true;

      final res = await _apiService.searchHotels(
        query: _query,
        limit: _pageSize,
        rid: 0,
        searchType: _searchType,
      );

      final List<Hotel> hotels = List<Hotel>.from(res['hotels'] ?? []);
      _hasMore = res['hasMore'] ?? (hotels.length >= _pageSize);

      emit(SearchLoaded(results: hotels, rid: 0, hasMore: _hasMore));
    } catch (e) {
      emit(SearchError(e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _onSearchLoadMore(SearchLoadMore event, Emitter<SearchState> emit) async {
    if (!_hasMore || _isLoading || state is! SearchLoaded) return;
    final current = state as SearchLoaded;

    try {
      _isLoading = true;

      final preloaderIds = current.results
          .map((h) => h.code)
          .where((id) => id.isNotEmpty)
          .toList();

      final res = await _apiService.searchHotels(
        query: _query,
        limit: _pageSize,
        rid: current.rid + _pageSize,
        searchType: _searchType,
        preloaderList: preloaderIds,
      );

      final List<Hotel> more = List<Hotel>.from(res['hotels'] ?? []);
      _hasMore = res['hasMore'] ?? (more.length >= _pageSize);

      if (more.isEmpty) {
        _hasMore = false;
        return;
      }

      final combined = List<Hotel>.from(current.results)..addAll(more);
      emit(SearchLoaded(results: combined, rid: current.rid + _pageSize, hasMore: _hasMore));
    } catch (e) {
      emit(SearchError(e.toString()));
    } finally {
      _isLoading = false;
    }
  }
}
