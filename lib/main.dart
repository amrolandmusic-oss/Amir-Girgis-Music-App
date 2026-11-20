import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const Color gold = Color(0xFFD6B45A);
const Color bg = Color(0xFF090909);
const Color panel = Color(0xFF171717);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AmirGirgisApp());
}

// --------------------------------------------------
// MUSIC LIBRARY
// --------------------------------------------------

class Track {
  final String title;
  final String asset;

  const Track({
    required this.title,
    required this.asset,
  });
}

const List<Track> tracks = [
  Track(
    title: 'النور مكانه في القلوب',
    asset: 'assets/audio/alnoor_makano.mp3',
  ),
  Track(
    title: 'بالورقة والقلم',
    asset: 'assets/audio/belwaraa_walalam.mp3',
  ),
  Track(
    title: 'تتر مسلسل ذهاب وعودة',
    asset: 'assets/audio/theme_zehab_wa_awda.mp3',
  ),
  Track(
    title: 'خليني في حضنك',
    asset: 'assets/audio/khalini_fi_hodnak.mp3',
  ),
  Track(
    title: 'قلب واحد',
    asset: 'assets/audio/qalb_wahed.mp3',
  ),
  Track(
    title: 'مش لاقي نفسي',
    asset: 'assets/audio/mesh_laqi_nafsi.mp3',
  ),
  Track(
    title: 'موطني',
    asset: 'assets/audio/mawtini.mp3',
  ),
  Track(
    title: 'وجع البعاد',
    asset: 'assets/audio/waga_elboad.mp3',
  ),
  Track(
    title: 'ياريتك فاهمني',
    asset: 'assets/audio/yaritak_fahimni.mp3',
  ),
  Track(
    title: 'داري يا قلبي',
    asset: 'assets/audio/dari_ya_albi.mp3',
  ),
];

// --------------------------------------------------
// APPLICATION
// --------------------------------------------------

class AmirGirgisApp extends StatelessWidget {
  const AmirGirgisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amir Girgis Music',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: gold,
          surface: panel,
        ),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
    );
  }
}

// --------------------------------------------------
// HOME PAGE
// --------------------------------------------------

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  late final AudioPlayer player;

  StreamSubscription<PlayerState>? playerSubscription;

  int? currentIndex;
  bool loading = false;
  bool searching = false;

  String searchText = '';
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    player = AudioPlayer();

    playerSubscription = player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    playerSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // PLAY A SONG
  // ------------------------------------------------

  Future<void> playTrack(int index) async {
    if (index < 0 || index >= tracks.length) return;
    if (loading) return;

    setState(() {
      loading = true;
      errorMessage = null;
      currentIndex = index;
    });

    try {
      final track = tracks[index];

     final source = AudioSource.asset(track.asset);
await player.setAudioSource(source);
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      player.play();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'تعذر تشغيل الأغنية';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تشغيل الملف: $error'),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  // ------------------------------------------------
  // PLAY / PAUSE
  // ------------------------------------------------

  Future<void> togglePlayback() async {
    if (loading) return;

    if (player.playing) {
      await player.pause();
      return;
    }

    if (currentIndex == null) {
      await playTrack(0);
      return;
    }

    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }

    player.play();
  }

  // ------------------------------------------------
  // NEXT / PREVIOUS
  // ------------------------------------------------

  Future<void> playNext() async {
    final nextIndex = currentIndex == null
        ? 0
        : (currentIndex! + 1) % tracks.length;

    await playTrack(nextIndex);
  }

  Future<void> playPrevious() async {
    final previousIndex = currentIndex == null
        ? 0
        : (currentIndex! - 1 + tracks.length) % tracks.length;

    await playTrack(previousIndex);
  }

  // ------------------------------------------------
  // TIME FORMAT
  // ------------------------------------------------

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ------------------------------------------------
  // MAIN SCREEN
  // ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final visibleTracks = tracks.asMap().entries.where((entry) {
      return entry.value.title.contains(searchText.trim());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: searching
            ? TextField(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'ابحث عن أغنية...',
                  border: InputBorder.none,
                ),
              )
            : const Text(
                'AMIR GIRGIS',
                style: TextStyle(
                  color: gold,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              searching ? Icons.close : Icons.search,
              color: gold,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                searching = !searching;
                searchText = '';
              });
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                children: [
                  _buildHero(),

                  const SizedBox(height: 28),

                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'مكتبتي الموسيقية',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '10 TRACKS',
                        style: TextStyle(
                          color: gold,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ...visibleTracks.map((entry) {
                    return _buildTrackTile(
                      entry.key,
                      entry.value,
                    );
                  }),

                  if (visibleTracks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: Text('لا توجد أغنيات مطابقة للبحث'),
                      ),
                    ),
                ],
              ),
            ),

            _buildPlayerBar(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // HERO SECTION
  // ------------------------------------------------

  Widget _buildHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          SizedBox(
            height: 290,
            width: double.infinity,
            child: Image.asset(
              'assets/images/album_cover.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Container(
                  color: panel,
                  child: const Center(
                    child: Icon(
                      Icons.music_note,
                      color: gold,
                      size: 80,
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            height: 290,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: gold.withOpacity(.8),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(.25),
                  Colors.black.withOpacity(.92),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'AMIR GIRGIS',
                  style: TextStyle(
                    color: gold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'OFFICIAL MUSIC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 15),

                OutlinedButton.icon(
                  onPressed: () => playTrack(0),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('استمع الآن'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: gold,
                    side: const BorderSide(color: gold, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // TRACK TILE
  // ------------------------------------------------

  Widget _buildTrackTile(int index, Track track) {
    final active = currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF28200E) : panel,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: active ? gold.withOpacity(.75) : Colors.white12,
          width: 1.2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 7,
        ),
        onTap: () => playTrack(index),

        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/songs_artwork.png',
            width: 65,
            height: 65,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) {
              return const SizedBox(
                width: 65,
                height: 65,
                child: Icon(Icons.music_note, color: gold),
              );
            },
          ),
        ),

        title: Text(
          track.title,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: active ? gold : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: const Text(
          'Amir Girgis',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),

        trailing: Icon(
          active && player.playing
              ? Icons.equalizer
              : Icons.play_circle_outline,
          color: gold,
          size: 34,
        ),
      ),
    );
  }

  // ------------------------------------------------
  // BOTTOM PLAYER
  // ------------------------------------------------

  Widget _buildPlayerBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(
          top: BorderSide(
            color: Color(0x55D6B45A),
            width: 1,
          ),
        ),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.graphic_eq,
                color: gold,
                size: 26,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  currentIndex == null
                      ? 'اختر أغنية للاستماع'
                      : tracks[currentIndex!].title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                onPressed: playPrevious,
                icon: const Icon(Icons.skip_previous),
                color: gold,
              ),

              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;

                  return IconButton(
                    onPressed: togglePlayback,
                    iconSize: 43,
                    color: gold,
                    icon: loading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: gold,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            playing
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                          ),
                  );
                },
              ),

              IconButton(
                onPressed: playNext,
                icon: const Icon(Icons.skip_next),
                color: gold,
              ),
            ],
          ),

          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, positionSnapshot) {
              final position =
                  positionSnapshot.data ?? Duration.zero;

              final duration =
                  player.duration ?? Duration.zero;

              final maxValue =
                  duration.inMilliseconds.toDouble();

              final currentValue = maxValue <= 0
                  ? 0.0
                  : position.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble();

              return Column(
                children: [
                  Slider(
                    value: currentValue,
                    max: maxValue <= 0 ? 1 : maxValue,
                    activeColor: gold,
                    inactiveColor: Colors.white12,
                    onChanged: maxValue <= 0
                        ? null
                        : (value) {
                            player.seek(
                              Duration(
                                milliseconds: value.round(),
                              ),
                            );
                          },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(position),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        formatTime(duration),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          if (errorMessage != null)
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
