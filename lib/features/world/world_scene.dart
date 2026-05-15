import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'timeline_page.dart';

class WorldScene extends StatefulWidget {
  final String title;
  final String image;
  final String videoPath;

  const WorldScene({
    super.key,
    required this.title,
    required this.image,
    required this.videoPath,
  });

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
          _controller.setVolume(0.0);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70), 
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. VIDEO BACKGROUND
          Positioned.fill(
            child: _initialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : Image.asset(widget.image, fit: BoxFit.cover),
          ),

          // 2. DIMMED COZY OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Slightly darker top to ground the title
                    Colors.black.withOpacity(0.35),      
                    Colors.transparent,                  
                    // Toned down the bottom brand color to 0.85 for a "dim" feel
                    const Color(0xFFF3EEF5).withOpacity(0.85), 
                  ],
                  stops: const [0.0, 0.5, 0.95], 
                ),
              ),
            ),
          ),

          // 3. MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // TITLE: Black text with a softer, slightly darker pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4), // Lowered opacity to dim it
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // STATUS PILL (Dimmed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "World Loaded 🎮",
                    style: GoogleFonts.fredoka(
                      fontSize: 15, 
                      color: Colors.white70, 
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // ACTION BUTTON: Darker White with Soft Amber Edge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.85), // Less "shiny" white
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        // Soft amber-orange glow (toned down)
                        shadowColor: Colors.orangeAccent.withOpacity(0.3),
                        side: BorderSide(color: Colors.orangeAccent.withOpacity(0.15), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ).copyWith(
                        elevation: WidgetStateProperty.all(4), // Lowered elevation
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimelinePage(
                            worldTitle: widget.title,
                            worldImage: widget.image,
                          ),
                        ),
                      ),
                      child: Text(
                        "Open Timeline 📖",
                        style: GoogleFonts.fredoka(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}