import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to fetch FEN notation from API
class FenApiService {
  /// Fetch FEN from API endpoint
  /// 
  /// Example usage:
  /// ```dart
  final fen =  FenApiService.fetchFen('https://api.example.com/chess/fen');
  /// ```
  static Future<String?> fetchFen(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Assuming API returns JSON like: {"fen": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"}
        if (data is Map<String, dynamic> && data.containsKey('fen')) {
          return data['fen'] as String;
        }
        
        // If API returns just the FEN string directly
        if (data is String) {
          return data;
        }
        
        return null;
      } else {
        print('Failed to fetch FEN: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching FEN: $e');
      return null;
    }
  }

  /// Fetch FEN with custom headers
  static Future<String?> fetchFenWithHeaders(
    String url,
    Map<String, String> headers,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('fen')) {
          return data['fen'] as String;
        }
        
        if (data is String) {
          return data;
        }
        
        return null;
      } else {
        print('Failed to fetch FEN: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching FEN: $e');
      return null;
    }
  }

  /// POST request to send current FEN and get new FEN
  static Future<String?> postFen(String url, String currentFen) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fen': currentFen}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('fen')) {
          return data['fen'] as String;
        }
        
        return null;
      } else {
        print('Failed to post FEN: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error posting FEN: $e');
      return null;
    }
  }
}