import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wakelock/wakelock.dart';

import 'package:coffee_journal/bloc/brew_bloc.dart';
import 'package:coffee_journal/model/brew.dart';

import 'extensions.dart';

class BrewInProgress extends StatefulWidget {
  BrewInProgress({Key? key}) : super(key: key);

  final BrewBloc brewBloc = BrewBloc();

  @override
  _BrewInProgressState createState() => _BrewInProgressState();
}

class _BrewInProgressState extends State<BrewInProgress> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    Wakelock.enable();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
    Wakelock.disable();
    widget.brewBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Brew;
    final previousBrew = widget.brewBloc.getBrewByRoasterAndBlend(args.roaster, args.blend);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee is brewing'),
      ),
      body: Center(
        child:
          FutureBuilder<Brew>(
            future: previousBrew,
            builder: (BuildContext context, AsyncSnapshot<Brew> snapshot) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "${args.roaster} : ${args.blend}",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "${args.dose}${args.doseMeasurement} coffee with ${args.water}${args.waterMeasurement} water",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (snapshot.hasData)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          "Previous brew time: ${Duration(seconds: snapshot.data?.duration ?? 0).format()}",
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: StreamBuilder<int>(
                        stream: _stopWatchTimer.rawTime,
                        initialData: _stopWatchTimer.rawTime.value,
                        builder: (context, snap) {
                          final value = snap.data!;
                          final displayTime =
                          StopWatchTimer.getDisplayTime(value, hours: false, milliSecond: false);
                          return Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  displayTime,
                                  style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _stopBrew(args);
                                    },
                                    child: const Text('Stop'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ]);
            },
          )
        ));
  }

  void _stopBrew(Brew brew) async {
    developer.log("Stopping brew");
    _stopWatchTimer.onExecute
        .add(StopWatchExecute.stop);
    brew.duration = _stopWatchTimer.secondTime.value;
    await widget.brewBloc.addBrew(brew);
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
