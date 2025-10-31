import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../data/services/api_service.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();

  void _onSearch(String query, {String type = 'citySearch'}) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(query: query.trim(), type: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Hotels')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TypeAheadField<String>(
              controller: _controller,
              debounceDuration: const Duration(milliseconds: 300),
              suggestionsCallback: (pattern) async {
                if (pattern.trim().length < 3) return [];
                final results = await _apiService.searchAutoComplete(pattern);
                // ✅ Convert List<Map> → List<String>
                return results
                    .map((e) => e['display']?.toString() ?? '')
                    .where((s) => s.isNotEmpty)
                    .toList();
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search city, state, or country...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (value) => _onSearch(value),
                );
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(suggestion),
                );
              },
              onSelected: (suggestion) {
                _controller.text = suggestion;
                _onSearch(suggestion);
              },
              emptyBuilder: (context) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No results found'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _onSearch(_controller.text),
              icon: const Icon(Icons.search),
              label: const Text('Search Hotels'),
            ),
          ],
        ),
      ),
    );
  }
}
