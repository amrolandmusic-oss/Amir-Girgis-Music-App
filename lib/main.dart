import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.amir.girgis.music.audio',
    androidNotificationChannelName: 'Amir Girgis Music',
    androidNotificationOngoing: true,
  );
  runApp(const AmirGirgisApp());
}

const gold = Color(0xFFD6B45A);
const bg = Color(0xFF090909);
const panel = Color(0xFF171717);

class Track {
  final String title;
  final String? asset;
  final String? streamUrl;
  const Track({required this.title, this.asset, this.streamUrl});
}

const tracks = <Track>[
  Track(title: 'النور مكانه في القلوب', asset: 'assets/audio/alnoor_makano.mp3'),
  Track(title: 'بالورقة والقلم', asset: 'assets/audio/belwaraa_walalam.mp3'),
  Track(title: 'تتر مسلسل ذهاب وعودة', asset: 'assets/audio/theme_zehab_wa_awda.mp3'),
  Track(title: 'خليني في حضنك', asset: 'assets/audio/khalini_fi_hodnak.mp3'),
  Track(title: 'قلب واحد', asset: 'assets/audio/qalb_wahed.mp3'),
  Track(title: 'مش لاقي نفسي', asset: 'assets/audio/mesh_laqi_nafsi.mp3'),
  Track(title: 'موطني', asset: 'assets/audio/mawtini.mp3'),
  Track(title: 'وجع البعاد', asset: 'assets/audio/waga_elboad.mp3'),
  Track(title: 'ياريتك فاهمني', asset: 'assets/audio/yaritak_fahimni.mp3'),
  Track(title: 'داري يا قلبي', asset: 'assets/audio/dari_ya_albi.mp3'),
];

class AmirGirgisApp extends StatelessWidget {
  const AmirGirgisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amir Girgis',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold, secondary: gold, surface: panel,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});
  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  late final AudioPlayer player;
  int? currentIndex;
  bool isSearching = false;
  String query = '';

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.currentIndexStream.listen((index) {
      if (mounted) setState(() => currentIndex = index);
    });
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final sources = tracks.map((track) {
      final mediaTag = MediaItem(
      id: track.streamUrl ?? track.asset ?? track.title,
      title: track.title,
      artist: 'Amir Girgis',
      album: 'Amir Girgis Music',
    );
    if (track.streamUrl != null && track.streamUrl!.isNotEmpty) {
      return AudioSource.uri(Uri.parse(track.streamUrl!), tag: mediaTag);
    }
    return AudioSource.asset(track.asset!, tag: mediaTag);
    }).toList();
    await player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: 0,
      preload: false,
    );
  }

  Future<void> playTrack(int index) async {
    try {
      if (player.audioSource == null) await _loadPlaylist();
      await player.seek(Duration.zero, index: index);
      await player.play();
      if (mounted) setState(() => currentIndex = index);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تشغيل الملف: $e')),
      );
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = tracks.asMap().entries.where((entry) =>
      entry.value.title.toLowerCase().contains(query.trim().toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        titleSpacing: 20,
        title: isSearching
          ? TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'ابحث عن أغنية...',
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() => query = value),
            )
          : const Text('AMIR GIRGIS',
              style: TextStyle(
                color: gold, fontWeight: FontWeight.w800,
                letterSpacing: 2.4, fontSize: 18,
              )),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: gold),
            onPressed: () => setState(() {
              isSearching = !isSearching;
              query = '';
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                children: [
                  _hero(),
                  const SizedBox(height: 26),
                  Row(
                    children: const [
                      Expanded(child: Text('مكتبتي الموسيقية',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      Text('10 TRACKS', style: TextStyle(
                        color: gold, fontSize: 10, letterSpacing: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...visible.map((entry) => _trackTile(entry.key, entry.value)),
                ],
              ),
            ),
            _playerBar(),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          SizedBox(
            width: double.infinity,
            height: 265,
            child: Image.asset(
              'assets/images/album_cover.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(
            height: 265,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(.05),
                  Colors.black.withOpacity(.35),
                  Colors.black.withOpacity(.92),
                ],
              ),
              border: Border.all(color: gold.withOpacity(.75), width: 1.2),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AMIR GIRGIS',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'OFFICIAL MUSIC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => playTrack(0),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('استمع الآن'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: gold,
                    backgroundColor: Colors.black.withOpacity(.48),
                    side: const BorderSide(color: gold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackTile(int index, Track track) {
    return StreamBuilder<SequenceState?>(
      stream: player.sequenceStateStream,
      builder: (context, snapshot) {
        final active = snapshot.data?.currentIndex == index;
        return Container(
          margin: const EdgeInsets.only(bottom: 9),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF241E10) : panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: active ? gold.withOpacity(.55) : Colors.white10),
          ),
          child: ListTile(
            onTap: () => playTrack(index),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/songs_artwork.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(track.title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: active ? gold : Colors.white,
                fontWeight: FontWeight.w600,
              )),
            subtitle: const Text('Amir Girgis',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
            trailing: Icon(
              active && player.playing ? Icons.equalizer_rounded : Icons.play_circle_outline,
              color: gold,
            ),
          ),
        );
      },
    );
  }

  Widget _playerBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(top: BorderSide(color: Color(0x55D6B45A))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) {
              final idx = snapshot.data?.currentIndex;
              final title = idx == null ? 'اختر أغنية للاستماع' : tracks[idx].title;
              return Row(
                children: [
                  const Icon(Icons.graphic_eq, color: gold),
                  const SizedBox(width: 10),
                  Expanded(child: Text(title, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, snap) {
                      final playing = snap.data?.playing ?? false;
                      return IconButton(
                        onPressed: () {
                          if (playing) { player.pause(); }
                          else if (player.audioSource != null) { player.play(); }
                        },
                        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: gold, size: 38),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, positionSnap) {
              final duration = player.duration ?? Duration.zero;
              final position = positionSnap.data ?? Duration.zero;
              final max = duration.inMilliseconds.toDouble();
              final value = max <= 0 ? 0.0 :
                position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble();
              return Column(
                children: [
                  Slider(
                    value: value,
                    max: max <= 0 ? 1 : max,
                    onChanged: max <= 0 ? null : (v) =>
                      player.seek(Duration(milliseconds: v.round())),
                    activeColor: gold,
                    inactiveColor: Colors.white12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_time(position), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      Text(_time(duration), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _time(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
