import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/blocs/search/search_bloc.dart';
import '../../../logic/blocs/search/search_event.dart';
import '../../../logic/blocs/search/search_state.dart';
import '../../../data/models/hotel.dart';
import '../../widgets/hotel_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  final String type;
  final String? display;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.type,
    this.display,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _scrollController = ScrollController();
  late SearchBloc _bloc;

  bool _autoLoading = false; // 👈 prevent infinite pagination loop

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SearchBloc>();
    _bloc.add(SearchStarted(widget.query, widget.type));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _bloc.add(SearchLoadMore());
    }
  }

  /// 🔹 Smart pagination trigger — only once per short list
  void _checkIfNeedMoreData(SearchState state) {
    if (state is SearchLoaded && state.hasMore && !_autoLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final position = _scrollController.position;

        if (position.maxScrollExtent <= position.viewportDimension) {
          _autoLoading = true; // prevent multiple triggers
          _bloc.add(SearchLoadMore());
        }
      });
    }

    // ✅ reset flag once data loaded successfully
    if (state is SearchLoaded && !_scrollController.hasClients) {
      _autoLoading = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBottomLoader() => const Padding(
    padding: EdgeInsets.all(12),
    child: Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        automaticallyImplyLeading: true,
        title: Text(
          'Results for "${Uri.decodeComponent(widget.display ?? widget.query)}"',
        ),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) => _checkIfNeedMoreData(state),
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is SearchLoaded) {
            final results = state.results;
            if (results.isEmpty) {
              return const Center(child: Text('No hotels found.'));
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 32, top: 8),
              itemCount: results.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= results.length) {
                  return _buildBottomLoader();
                }
                final hotel = results[index];
                return HotelCard(hotel: hotel);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
