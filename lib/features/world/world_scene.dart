import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'timeline_page.dart';

class WorldScene extends StatefulWidget {
  final String title;
  final String image;
  final String videoPath;

  const WorldScene({super.key, required this.title, required this.image, required this.videoPath});

  @override
  State<WorldScene> createState() => _WorldSceneState();
}

class _WorldSceneState extends State<WorldScene> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.setVolume(0.0); // 🤫 Silent
          _controller.play();
          _controller.addListener(() {
            int loopTime = widget.title == "Shopping World 🛍️" ? 5 : 4;
            if (_controller.value.position >= Duration(seconds: loopTime)) {
              _controller.seekTo(Duration.zero);
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _initialized
                ? FittedBox(fit: BoxFit.cover, child: SizedBox(width: _controller.value.size.width, height: _controller.value.size.height, child: VideoPlayer(_controller)))
                : Image.asset(widget.image, fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(widget.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                const Text("World Loaded 🎮", style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TimelinePage(worldTitle: widget.title, worldImage: widget.image))),
                      child: const Text("Open Timeline 📖", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}