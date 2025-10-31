import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/blocs/home/home_bloc.dart';
import '../../../logic/blocs/home/home_event.dart';
import '../../../logic/blocs/home/home_state.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/hotel_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _suggestions = []; // 👈 structured data
  bool _loadingSuggestions = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadSampleHotels());
  }

  Future<void> _onSearchTextChanged(String text) async {
    if (text.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _loadingSuggestions = true);
    final list = await _apiService.searchAutoComplete(text.trim(), limit: 8);
    setState(() {
      _suggestions = list;
      _loadingSuggestions = false;
    });
  }

  void _submitSearch(Map<String, dynamic> suggestion) {
    _focusNode.unfocus();
    setState(() => _suggestions = []);

    final query = suggestion['query'] ?? '';
    final type = suggestion['type'] ?? 'citySearch';
    final display = suggestion['display'] ?? query;

    final encodedQuery = Uri.encodeComponent(query);
    final encodedType = Uri.encodeComponent(type);
    final encodedDisplay = Uri.encodeComponent(display);

    print('🔍 Navigating to search page: $display [$type:$query]');
    context.go('/search?q=$encodedQuery&type=$encodedType&display=$encodedDisplay');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hotels')),
      body: GestureDetector(
        onTap: () => _focusNode.unfocus(),
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search by hotel, city, state or country',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        onChanged: _onSearchTextChanged,
                      ),
                      if (_loadingSuggestions)
                        const LinearProgressIndicator(minHeight: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is HomeError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      if (state is HomeLoaded) {
                        final hotels = state.hotels;
                        if (hotels.isEmpty) {
                          return const Center(child: Text('No hotels found.'));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: hotels.length,
                          itemBuilder: (context, index) =>
                              HotelCard(hotel: hotels[index]),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),

            // 👇 Floating suggestion dropdown
            if (_suggestions.isNotEmpty && _focusNode.hasFocus)
              Positioned(
                top: 85,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, i) {
                        final s = _suggestions[i];
                        return ListTile(
                          dense: true,
                          title: Text(s['display'] ?? ''),
                          onTap: () => _submitSearch(s),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
