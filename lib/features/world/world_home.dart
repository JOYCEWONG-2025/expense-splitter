import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'world_scene.dart';

class WorldHome extends StatefulWidget {
  const WorldHome({super.key});

  @override
  State<WorldHome> createState() => _WorldHomeState();
}

class _WorldHomeState extends State<WorldHome> {
  final PageController _controller = PageController(viewportFraction: 0.78);
  double currentPage = 0;

  final List<Map<String, String>> worlds = [
    {
      "title": "Food World 🍔",
      "desc": "Track your meals & snacks",
      "image": "assets/backgrounds/food.jpg",
      "video": "assets/videos/food.MP4",
      "emotion": "happy",
    },
    {
      "title": "Transport World 🚗",
      "desc": "Travel & commute expenses",
      "image": "assets/backgrounds/transport.jpg",
      "video": "assets/videos/transport.MP4",
      "emotion": "fast",
    },
    {
      "title": "Shopping World 🛍️",
      "desc": "All your shopping spending",
      "image": "assets/backgrounds/shopping.jpg",
      "video": "assets/videos/shopping.MOV",
      "emotion": "excited",
    },
    {
      "title": "Accommodation World 🏨",
      "desc": "Stay & lodging costs",
      "image": "assets/backgrounds/Accomo.jpg",
      "video": "assets/videos/Accomo.MP4",
      "emotion": "calm",
    },
    {
      "title": "Trip World ✈️",
      "desc": "Travel adventures & trips",
      "image": "assets/backgrounds/trip.jpg",
      "video": "assets/videos/trip.MP4",
      "emotion": "adventure",
    },
    {
      "title": "Others 🌈",
      "desc": "Custom / uncategorized expenses",
      "image": "assets/backgrounds/others.jpg",
      "video": "assets/videos/others.MP4",
      "emotion": "random",
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => currentPage = _controller.page ?? 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EEF5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Rabbit Expense Worlds 🐰",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Swipe to explore your expense adventure",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: worlds.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          double value =
                              (_controller.hasClients &&
                                  _controller.position.haveDimensions)
                              ? (_controller.page ?? 0) - index
                              : (index == 0 ? 0 : 1);
                          value = (1 - (value.abs() * 0.5)).clamp(0.6, 1.0);

                          return Center(
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..scale(value)
                                ..rotateY((1 - value) * -0.6),
                              child: Transform.translate(
                                offset: Offset(0, value < 0.8 ? 20 : 0),
                                child: Opacity(
                                  opacity: value,
                                  child: WorldCardItem(
                                    world: worlds[index],
                                    index: index,
                                    currentPage: currentPage,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    bottom: 20,
                    left:
                        (currentPage / (worlds.length - 1)) *
                        screenWidth *
                        0.65,
                    child: SizedBox(
                      height: 140,
                      width: 140,
                      child: Lottie.asset(
                        "assets/rabbits/Rabbit Kick Scooter.json",
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class WorldCardItem extends StatefulWidget {
  final Map<String, String> world;
  final int index;
  final double currentPage;
  const WorldCardItem({
    super.key,
    required this.world,
    required this.index,
    required this.currentPage,
  });

  @override
  State<WorldCardItem> createState() => _WorldCardItemState();
}

class _WorldCardItemState extends State<WorldCardItem> {
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Initialize video
    _videoController = VideoPlayerController.asset(widget.world["video"]!)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _videoController.setVolume(0.0);
          _videoController.play();

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _showVideo = true);
          });

          _videoController.addListener(() {
            int loopTime = widget.world["title"] == "Shopping World 🛍️"
                ? 5
                : 4;
            if (_videoController.value.position >=
                Duration(seconds: loopTime)) {
              _videoController.seekTo(Duration.zero);
            }
          });
        }
      });

    // Initial audio check
    _manageAudio();
  }

  @override
  void didUpdateWidget(WorldCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger audio management only when the page actually shifts
    if (oldWidget.currentPage != widget.currentPage) {
      _manageAudio();
    }
  }

  Future<void> _manageAudio() async {
    // Give the swipe 300ms to settle so we don't play sounds mid-swipe
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    int activeIndex = widget.currentPage.round();

    if (widget.index != activeIndex) {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }
      return;
    }

    // Play audio if this is the focused card and isn't already playing
    if (_audioPlayer.state != PlayerState.playing) {
      String soundPath = "";
      switch (widget.world["title"]) {
        case "Food World 🍔":
          soundPath = "sounds/food_sound.mp3";
          break;
        case "Transport World 🚗":
          soundPath = "sounds/transport_sound.mp3";
          break;
        case "Shopping World 🛍️":
          soundPath = "sounds/shopping_sound.mp3";
          break;
        case "Accommodation World 🏨":
          soundPath = "sounds/Acco_sound.mp3";
          break;
        case "Trip World ✈️":
          soundPath = "sounds/trip_sound.mp3";
          break;
        case "Others 🌈":
          soundPath = "sounds/other_sound.mp3";
          break;
      }

      if (soundPath.isNotEmpty) {
        try {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.play(AssetSource(soundPath), volume: 0.5);
        } catch (e) {
          debugPrint("🔈 Click the screen to enable audio.");
        }
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.92,
      child: Container(
        height: 560,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [
            BoxShadow(
              blurRadius: 25,
              color: Colors.black38,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: _isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : Container(color: Colors.black),
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showVideo ? 0.0 : 1.0,
                child: Image.asset(
                  widget.world["image"]!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  alignment: Alignment(
                    (widget.currentPage - widget.index) * 0.2,
                    0,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.world["title"]!,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.world["desc"]!,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorldScene(
                            title: widget.world["title"]!,
                            image: widget.world["image"]!,
                            videoPath: widget.world["video"]!,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Enter World ✨",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
