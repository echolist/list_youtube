import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  final String apiKey = 'AIzaSyCBHq8WZCz1f6-sFt7Jxt4kWKgqcfIFwlE';

  Future<List<Map<String, dynamic>>> fetchVideos(String keyword) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$keyword&type=video&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['items'].map((item) => {
            'title': item['snippet']['title'],
            'thumbnail': item['snippet']['thumbnails']['default']['url'],
            'videoId': item['id']['videoId'],
          }));
    } else {
      throw Exception('Failed to fetch videos');
    }
  }
}