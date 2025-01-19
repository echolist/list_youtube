import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'db_helper.dart';
import 'youtube_service.dart';
import 'package:list_youtube/video_player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();

  // Open the 'keywords' box
  await Hive.openBox<String>('keywords');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Keywords App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HiveHelper _hiveHelper = HiveHelper();
  final YouTubeService _youtubeService = YouTubeService();

  List<String> _keywords = [];
  List<Map<String, dynamic>> _videos = [];
  String? _selectedKeyword;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  Future<void> _loadKeywords() async {
    setState(() {
      _keywords = _hiveHelper.getKeywords();
    });
  }

  Future<void> _fetchVideos(String keyword) async {
    final videos = await _youtubeService.fetchVideos(keyword);
    setState(() {
      _videos = videos;
      _selectedKeyword = keyword;
    });
  }

  void _addKeyword() async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Keyword'),
        content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter keyword')),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _hiveHelper.addKeyword(controller.text);
                await _loadKeywords();
              }
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YouTube Keywords')),
      body: Column(
        children: [
          ElevatedButton(onPressed: _addKeyword, child: Text('Add Keyword')),
          if (_keywords.isNotEmpty)
            DropdownButton<String>(
              value: _selectedKeyword,
              hint: Text('Select a keyword'),
              items: _keywords.map((keyword) {
                return DropdownMenuItem(value: keyword, child: Text(keyword));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _fetchVideos(value);
                }
              },
            ),
          if (_videos.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: video['thumbnail'],
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.broken_image, size: 50),
                    ),
                    title: Text(video['title']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoId: video['videoId']!, // Pass the selected video ID
                            videos: _videos, // Pass the full list of videos
                          ),
                        ),
                      );
                      // Navigate to YouTube or handle video playback
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
