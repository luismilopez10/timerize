import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import 'package:timerize/settings/application_assets.dart';
import 'package:timerize/helpers/helpers.dart';
import 'package:timerize/models/models.dart';
import 'package:timerize/providers/providers.dart';

class TimerScreen extends StatefulWidget {
  static const String routerName = 'Timer';
  final ShowerSectionProvider? showerSectionProvider;

  const TimerScreen({
    Key? key,
    this.showerSectionProvider,
  }) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer timer;
  bool isPlaying = true;
  int currentIndex = 0;
  int localSecondsElapsed = 0;
  int totalCurrentSectionTimeInSeconds = 0;
  double timeElapsedPercentage = 0.0;
  int volume = 100;
  int lastVolume = 100;
  bool isMuted = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();
  CountdownController countdownController =
      CountdownController(autoStart: true);

  void _updateTimeElsapsedPercentage(Timer timer) {
    setState(() {
      timeElapsedPercentage =
          1 - (localSecondsElapsed / totalCurrentSectionTimeInSeconds);
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _beep() {
    audioPlayer.play(
      AssetSource(ApplicationAssets.sectionFinishedAudio),
      volume: volume / 100,
      mode: PlayerMode.lowLatency,
    );

    Future.delayed(const Duration(milliseconds: 1500)).then((value) {
      audioPlayer.stop();
    });
  }

  @override
  void initState() {
    super.initState();

    flutterTts.setLanguage('es-ES');
    flutterTts.setPitch(1);
    flutterTts.setVolume(volume.toDouble() / 100);
    _speak(
        'Inicia: ${widget.showerSectionProvider!.showerSectionList.elementAt(currentIndex).sectionName!}');

    timer = Timer.periodic(
        const Duration(milliseconds: 50), _updateTimeElsapsedPercentage);
  }

  @override
  void dispose() {
    timer.cancel();
    // audioPlayer.dispose(); //* No hacer dispose porque se corta el audio al finalizar todas las secciones por el .pop()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ShowerSection currentShowerSection =
        widget.showerSectionProvider!.showerSectionList.elementAt(currentIndex);

    totalCurrentSectionTimeInSeconds = currentShowerSection.seconds! +
        (widget.showerSectionProvider!.showerSectionList[currentIndex]
                .minutes! *
            60) +
        (widget.showerSectionProvider!.showerSectionList[currentIndex].hours! *
            3600);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reiniciar',
            onPressed: () {
              currentIndex = 0;
              countdownController.restart();
              isPlaying = false;
              Future.delayed(const Duration(milliseconds: 300))
                  .then((_) => countdownController.pause());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80.0),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  strokeAlign: 25.0,
                  value: timeElapsedPercentage,
                  strokeWidth: 10.0,
                  strokeCap: StrokeCap.round,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: currentIndex > 0
                              ? () {
                                  currentIndex -= 1;
                                  isPlaying = false;
                                  Future.delayed(
                                          const Duration(milliseconds: 300))
                                      .then((_) => countdownController.pause());
                                }
                              : null,
                          icon: Icon(
                            Icons.arrow_left,
                            size: 35.0,
                            color: currentIndex > 0
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.25),
                          ),
                        ),
                        SizedBox(
                          width: 150.0,
                          child: Text(
                            currentShowerSection.sectionName!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: currentIndex <
                                  widget.showerSectionProvider!
                                          .showerSectionList.length -
                                      1
                              ? () {
                                  currentIndex += 1;
                                  isPlaying = false;
                                  Future.delayed(
                                          const Duration(milliseconds: 300))
                                      .then((_) => countdownController.pause());
                                }
                              : null,
                          icon: Icon(
                            Icons.arrow_right,
                            size: 35.0,
                            color: currentIndex <
                                    widget.showerSectionProvider!
                                            .showerSectionList.length -
                                        1
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.25),
                          ),
                        ),
                      ],
                    ),
                    Countdown(
                      key: ValueKey<int>(currentIndex),
                      controller: countdownController,
                      seconds: totalCurrentSectionTimeInSeconds,
                      onFinished: () {
                        setState(() {
                          _beep();

                          if (currentIndex <
                              widget.showerSectionProvider!.showerSectionList
                                      .length -
                                  1) {
                            currentIndex++;
                            _speak(
                                'Inicia: ${widget.showerSectionProvider!.showerSectionList.elementAt(currentIndex).sectionName!}');
                          } else {
                            _speak('Se han concluído todas las secciones');
                            Navigator.pop(context);
                          }
                        });
                      },
                      build: (BuildContext context, double secondsElapsed) {
                        localSecondsElapsed = secondsElapsed.toInt();

                        final remainingSeconds = secondsElapsed % 60;
                        final minutes = secondsElapsed ~/ 60;
                        final remainingMinutes = minutes % 60;
                        final hours = minutes ~/ 60;

                        final String formattedSeconds =
                            remainingSeconds.toStringAsFixed(0).padLeft(2, '0');

                        final String formattedMinutes =
                            remainingMinutes.toStringAsFixed(0).padLeft(2, '0');

                        final String formattedHours =
                            hours.toStringAsFixed(0).padLeft(2, '0');

                        return Text(
                          '$formattedHours:$formattedMinutes:$formattedSeconds',
                          style: const TextStyle(
                            fontSize: 54.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 120.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  enableFeedback: true,
                  onPressed: !isPlaying
                      ? () {
                          countdownController.resume();
                          isPlaying = true;
                        }
                      : null,
                  child: Icon(
                    Icons.play_arrow,
                    size: 30.0,
                    color: !isPlaying
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.25),
                  ),
                ),
                MaterialButton(
                  enableFeedback: true,
                  onPressed: isPlaying
                      ? () {
                          countdownController.pause();
                          isPlaying = false;
                        }
                      : null,
                  child: Icon(
                    Icons.pause,
                    size: 30.0,
                    color: isPlaying
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.25),
                  ),
                ),
                MaterialButton(
                  enableFeedback: true,
                  onPressed: () =>
                      Helpers.showToast('Mantén presionado para reiniciar'),
                  onLongPress: () {
                    countdownController.restart();
                    isPlaying = false;
                    Future.delayed(const Duration(milliseconds: 300))
                        .then((_) => countdownController.pause());
                  },
                  child: const Icon(
                    Icons.restore,
                    size: 30.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50.0),
            Slider(
              activeColor: volume == 0
                  ? Colors.grey
                  : HSVColor.fromAHSV(
                      1.0,
                      HSVColor.fromColor(Theme.of(context).primaryColor).hue,
                      (volume + 150) * 0.2 / 100,
                      1.0,
                    ).toColor(),
              divisions: 100,
              min: 0,
              max: 100,
              label: '$volume',
              value: volume.toDouble(),
              onChanged: (double newValue) {
                setState(() {
                  volume = newValue.round();
                  lastVolume = volume;
                  flutterTts.setVolume(newValue / 100);
                  if (newValue != 0) {
                    isMuted = false;
                  }
                });
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: IconButton(
                  icon: volume == 0
                      ? const Icon(Icons.music_off)
                      : const Icon(Icons.music_note),
                  color: volume == 0 ? Colors.grey : null,
                  onPressed: () {
                    isMuted = !isMuted;
                    if (isMuted) {
                      lastVolume = volume;
                      volume = 0;
                    } else {
                      volume = lastVolume;
                    }

                    flutterTts.setVolume(volume / 100);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
