import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final List<Map<String, dynamic>> videos; // Add list of videos to the screen

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
    required this.videos,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late String _currentVideoId;

  @override
  void initState() {
    super.initState();
    _currentVideoId = widget.videoId;
    _controller = YoutubePlayerController(
      initialVideoId: _currentVideoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo(String videoId) {
    setState(() {
      _currentVideoId = videoId;
      _controller.load(videoId); // Load the new video
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Video'),
      ),
      body: Column(
        children: [
          // YouTube Player
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            progressColors: ProgressBarColors(
              playedColor: Colors.blue,
              handleColor: Colors.blueAccent,
            ),
          ),

          // Divider
          const Divider(),

          // Video List
          Expanded(
            child: ListView.builder(
              itemCount: widget.videos.length,
              itemBuilder: (context, index) {
                final video = widget.videos[index];
                return ListTile(
                  leading: Image.network(
                    video['thumbnail']!,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image),
                  ),
                  title: Text(video['title']!),
                  onTap: () {
                    _playVideo(video['videoId']!);
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
