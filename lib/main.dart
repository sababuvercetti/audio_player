import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: GridView.count(
        crossAxisCount: 4,
        children: List.generate(
            ref.read(vibesAudioProviders).length,
            (index) => MusicTile(
                  index: index,
                  player: ref.read(vibesAudioProviders)[index],
                )),
      )),
    );
  }
}

class MusicTile extends ConsumerStatefulWidget {
  final int index;
  final AudioPlayer player;
  const MusicTile({super.key, required this.index, required this.player});

  @override
  ConsumerState<MusicTile> createState() => _MusicTileState();
}

class _MusicTileState extends ConsumerState<MusicTile> {
  String url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3';

  @override
  void initState() {
    super.initState();
    setAudio();
  }

  setAudio() async {
    await widget.player.setReleaseMode(ReleaseMode.stop);
    await widget.player.setSourceUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    widget.player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        ref.read(currentSong.notifier).change(widget.index);
      } else if (event == PlayerState.paused) {}
    });
    return Card(
      child: Column(
        children: [
          const Text('Music Title'),
          const Text('Artist'),
          // Play button
          ref.watch(currentSong) == widget.index
              ?
              // Pause button
              CupertinoButton(
                  child: const Icon(Icons.pause),
                  onPressed: () async {
                    ref.read(currentSong.notifier).change(null);
                    await ref
                        .read(vibesAudioProviders.notifier)
                        .pause(widget.index);
                  })
              : CupertinoButton(
                  child: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    if (ref.read(currentSong) != null &&
                        ref.read(currentSong) != widget.index) {
                      await ref
                          .read(vibesAudioProviders)[ref.read(currentSong)!]
                          .stop();
                      widget.player.resume();
                    } else if (ref.read(currentSong) == null) {
                      widget.player.resume();
                    }
                  })
          // Pause button
        ],
      ),
    );
  }
}

class CurrentSongProvider extends StateNotifier<int?> {
  CurrentSongProvider() : super(null);
  change(index) {
    state = index;
  }
}

final currentSong = StateNotifierProvider<CurrentSongProvider, int?>((ref) {
  return CurrentSongProvider();
});

final vibesAudioProviders =
    StateNotifierProvider<VibesAudioProviders, List<AudioPlayer>>((ref) {
  return VibesAudioProviders();
});

class VibesAudioProviders extends StateNotifier<List<AudioPlayer>> {
  VibesAudioProviders() : super(List.generate(4, (_) => AudioPlayer()));

  pause(int song) {
    if (state[song].state == PlayerState.playing) {
      state[song].pause();
    }
  }
}
