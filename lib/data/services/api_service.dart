import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';

class ApiService {
  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();

  static const String _baseUrl = 'https://api.mytravaly.com/public/v1/';
  static const String _authToken = '71523fdd8d26f585315b4233e39d9263';

  String? _visitorToken;

  // Ensure visitor token exists before making API calls
  Future<void> _ensureVisitorToken() async {
    if (_visitorToken != null && _visitorToken!.isNotEmpty) return;

    final uri = Uri.parse(_baseUrl);
    final body = {
      "action": "deviceRegister",
      "deviceRegister": {
        "deviceModel": "flutter_device",
        "deviceFingerprint": DateTime.now().millisecondsSinceEpoch.toString(),
        "deviceBrand": "flutter",
        "deviceId": "flutter_device_${DateTime.now().microsecondsSinceEpoch}",
        "deviceName": "Flutter Emulator",
        "deviceManufacturer": "flutter",
        "deviceProduct": "flutter_product",
        "deviceSerialNumber": "SN-${DateTime.now().millisecondsSinceEpoch}"
      }
    };

    print('\n🔹 Registering device...');
    final resp = await client.post(
      uri,
      headers: {
        'authtoken': _authToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('🔹 Device Register Response (${resp.statusCode}): ${resp.body}');

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      try {
        final json = jsonDecode(resp.body);
        final visitor = json['data']?['visitorToken'] as String?;
        if (visitor != null && visitor.isNotEmpty) {
          _visitorToken = visitor;
          print('✅ Visitor token obtained: $_visitorToken');
        } else {
          print('⚠️ Visitor token missing in response');
        }
      } catch (e) {
        print('❌ Error parsing visitor token: $e');
      }
    } else {
      print('⚠️ Device registration failed: ${resp.statusCode}');
    }
  }

  Map<String, String> _headers() {
    final headers = {
      'authtoken': _authToken,
      'Content-Type': 'application/json',
    };
    if (_visitorToken != null) headers['visitortoken'] = _visitorToken!;
    return headers;
  }

  // Autocomplete API
  Future<List<Map<String, dynamic>>> searchAutoComplete(
      String inputText, {
        int limit = 8,
      }) async {
    await _ensureVisitorToken();
    final uri = Uri.parse(_baseUrl);
    final body = {
      "action": "searchAutoComplete",
      "searchAutoComplete": {
        "inputText": inputText,
        "searchType": ["byCity", "byState", "byCountry", "byPropertyName"],
        "limit": limit
      }
    };

    print('\n-------------------- AUTOCOMPLETE DEBUG --------------------');
    print('POST: $_baseUrl');
    print('Headers: ${_headers()}');
    print('Body: ${jsonEncode(body)}');
    print('------------------------------------------------------------');

    try {
      final resp =
      await client.post(uri, headers: _headers(), body: jsonEncode(body));
      print('Status Code: ${resp.statusCode}');
      print('Response: ${resp.body}');
      print('------------------------------------------------------------');

      if (resp.statusCode == 200) {
        final js = jsonDecode(resp.body);
        final data = js['data']?['autoCompleteList'] ?? {};
        final suggestions = <Map<String, dynamic>>[];

        data.forEach((category, info) {
          if (info is Map && info['listOfResult'] is List) {
            for (var item in info['listOfResult']) {
              suggestions.add({
                'display': item['valueToDisplay'] ?? '',
                'type': item['searchArray']?['type'] ?? '',
                'query': (item['searchArray']?['query'] as List?)?.first ?? '',
                'address': item['address'] ?? {},
              });
            }
          }
        });

        print('✅ Parsed ${suggestions.length} autocomplete suggestions');
        return suggestions;
      } else {
        print('⚠️ Autocomplete non-200: ${resp.statusCode}');
      }
    } catch (e) {
      print('❌ Autocomplete error: $e');
    }

    return [];
  }

  // Hotel search API with fallback logic for strict API
  Future<Map<String, dynamic>> searchHotels({
    required String query,
    int limit = 5,
    int rid = 0,
    String? searchType,
    List<String>? preloaderList,
    String checkIn = '2026-07-11',
    String checkOut = '2026-07-12',
    int rooms = 1,
    int adults = 2,
    int children = 0,
  }) async {
    await _ensureVisitorToken();
    final uri = Uri.parse(_baseUrl);

    String finalQuery = query.trim();
    String effectiveType = searchType ?? 'citySearch';

    // Step 1️⃣ — Skip autocomplete for hotelIdSearch
    if (effectiveType == 'hotelIdSearch') {
      finalQuery = query.trim();
    } else {
      // Step 2️⃣ — Use autocomplete for better address resolution
      final suggestions = await searchAutoComplete(query);
      if (suggestions.isNotEmpty) {
        final first = suggestions.first;
        effectiveType = first['type'] ?? effectiveType;

        if (effectiveType == 'hotelIdSearch') {
          finalQuery = first['query'] ?? query.trim();
        } else if (first['address'] is Map) {
          final address = first['address'] as Map<String, dynamic>;
          final city = address['city']?.toString().trim() ?? '';
          final state = address['state']?.toString().trim() ?? '';
          String country = address['country']?.toString().trim() ?? '';
          if (country.isEmpty && (city.isNotEmpty || state.isNotEmpty)) {
            country = 'India';
          }

          if (effectiveType == 'citySearch' && city.isNotEmpty) {
            finalQuery = '$city${state.isNotEmpty ? ", $state" : ""}, $country';
          } else if (effectiveType == 'stateSearch' && state.isNotEmpty) {
            finalQuery = '$state, $country';
          } else {
            finalQuery = [city, state, country]
                .where((e) => e.toString().trim().isNotEmpty)
                .join(', ');
          }
        }
      } else {
        // Fallback: ensure country added
        if (!query.toLowerCase().contains('india')) {
          finalQuery = '$query, India';
        }
      }
    }

    // Step 3️⃣ — Call API once
    Future<http.Response> _doRequest(String type) async {
      final body = {
        "action": "getSearchResultListOfHotels",
        "getSearchResultListOfHotels": {
          "searchCriteria": {
            "checkIn": checkIn,
            "checkOut": checkOut,
            "rooms": rooms,
            "adults": adults,
            "children": children,
            "searchType": type,
            "searchQuery": [finalQuery],
            "accommodation": ["all", "hotel"],
            "arrayOfExcludedSearchType": [],
            "highPrice": "3000000",
            "lowPrice": "0",
            "limit": limit.clamp(1, 5),
            "preloaderList": preloaderList ?? [],
            "currency": "INR",
            "rid": rid,
          }
        }
      };

      print('\n-------------------- API DEBUG --------------------');
      print('POST: $_baseUrl');
      print('Search Type: $type');
      print('Final Query: $finalQuery');
      print('Headers: ${_headers()}');
      print('---------------------------------------------------');

      return await client.post(uri, headers: _headers(), body: jsonEncode(body));
    }

    // Step 4️⃣ — Try request and handle fallback on 400
    http.Response resp = await _doRequest(effectiveType);
    if (resp.statusCode == 400 && effectiveType != 'hotelIdSearch') {
      print('⚠️ 400 error for $effectiveType — retrying with fallback...');
      if (effectiveType == 'citySearch') {
        effectiveType = 'stateSearch';
      } else if (effectiveType == 'stateSearch') {
        effectiveType = 'countrySearch';
      }
      resp = await _doRequest(effectiveType);
    }

    // Step 5️⃣ — Parse response
    print('Status Code: ${resp.statusCode}');
    print('Response: ${resp.body}');
    print('---------------------------------------------------');

    if (resp.statusCode == 200) {
      final js = jsonDecode(resp.body);
      var items = <dynamic>[];
      if (js['data'] is Map) {
        final map = js['data'] as Map<String, dynamic>;
        map.forEach((k, v) {
          if (v is List && items.isEmpty) items = v;
        });
      }

      print('✅ Parsed ${items.length} items');

      final hotels = items.map<Hotel>((e) {
        try {
          return Hotel.fromJson(Map<String, dynamic>.from(e));
        } catch (_) {
          return Hotel(
            id: '',
            name: 'Unknown',
            imageUrl: null,
            code: '',
            city: '',
            state: '',
            country: '',
            propertyUrl: '',
          );
        }
      }).toList();

      final hasMore = hotels.length >= limit;
      return {'hotels': hotels, 'hasMore': hasMore};
    }

    print('⚠️ Non-200 Response: ${resp.statusCode}');
    return {'hotels': <Hotel>[], 'hasMore': false};
  }

}
