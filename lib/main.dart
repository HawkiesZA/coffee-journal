import 'dart:ui';

import 'package:coffee_journal/create_or_edit_brew.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';
import 'constants.dart';
import 'firebase_options.dart';
import 'package:coffee_journal/bloc/brew_bloc.dart';
import 'package:coffee_journal/brew_details.dart';
import 'package:coffee_journal/model/brew.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main_search_delegate.dart';
import 'routes.dart';
import 'brew_in_progress.dart';
import 'extensions.dart';

import 'dart:developer' as developer;

late SharedPreferences sp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  sp = await SharedPreferences.getInstance();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Coffee Journal',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CoffeeJournal(title: 'Coffee Journal'),
      routes: <String, WidgetBuilder> {
        brewDetails: (BuildContext context) => BrewDetails(),
        newBrew: (BuildContext context) => CreateOrEditBrew(),
        brewInProgress: (BuildContext context) => BrewInProgress(),
        editBrew: (BuildContext context) => CreateOrEditBrew(),
      },
    );
  }
}

class CoffeeJournal extends StatefulWidget {
  CoffeeJournal({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _CoffeeJournalState createState() => _CoffeeJournalState();
}

class _CoffeeJournalState extends State<CoffeeJournal> {
  late final BrewBloc brewBloc;
  late ScrollController controller;
  bool fabIsVisible = true;
  List<Brew> brews = List.empty();
  int _selectedIndex = 0;

  void search(String searchString) {
    developer.log("Searching");
    brewBloc.searchBrews(query: searchString);
  }

  @override
  initState() {
    super.initState();
    brewBloc = BrewBloc();
    controller = ScrollController();
    controller.addListener(() {
      if ((controller.position.userScrollDirection == ScrollDirection.forward && !fabIsVisible) ||
          (controller.position.userScrollDirection == ScrollDirection.reverse && fabIsVisible)) {

        setState(() {
          fabIsVisible =
              controller.position.userScrollDirection == ScrollDirection.forward;
        });
      }

    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // user is signed out
        signInWithGoogle();
      } else {
        // user is signed in, woot!
        // migrate data from sqlite to firebase // TODO: remove this in the next version
        final brews = await brewBloc.getBrewsSqlite();
        if (brews.isNotEmpty) {
          for (var brew in brews) {
            brewBloc.addBrew(brew);
            brewBloc.deleteBrewSqlite(brew.id!);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log("Building main widget");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              final searchValue = await showSearch(
                  context: context,
                  delegate: MainSearchDelegate(brews)
              );
              search(searchValue);
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: _buildScreen(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: fabIsVisible ? FloatingActionButton(
        onPressed: _newBrew,
        tooltip: 'New Brew',
        child: Icon(Icons.coffee),
      ) : null,
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return _buildList();
      default: return _buildSettings();
    }
  }

  Widget _buildList() {
    developer.log("Building list");
    return StreamBuilder(
        stream: brewBloc.brews,
        builder: (BuildContext context, AsyncSnapshot<List<Brew>> snapshot) {
          return _buildListItem(snapshot);
        });
  }

  Widget _buildListItem(AsyncSnapshot<List<Brew>> snapshot) {
    if (snapshot.hasData) {
      brews = snapshot.requireData;
      return snapshot.requireData.length != 0
          ? RefreshIndicator(
          onRefresh: () async {
            _refresh();
          },
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: controller,
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.requireData.length,
              itemBuilder: (context, i) {
                Brew brew = snapshot.requireData[i];
                final index = i ~/ 2;
                if (index >= snapshot.requireData.length) {
                  // TODO: fetch more entries
                }
                return _buildRow(brew);
              })
      )
          : Container(
          child: Center(
            child: noBrewMessageWidget(),
          ));
    } else {
      return Center(
        /*since most of our I/O operations are done
        outside the main thread asynchronously
        we may want to display a loading indicator
        to let the use know the app is currently
        processing*/
        child: loadingData(),
      );
    }
  }

  Widget noBrewMessageWidget() {
    return Container(
      child: Text(
        "No brews yet. Let's brew some coffee!",
      ),
    );
  }

  Widget loadingData() {
    brewBloc.getBrews();
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Text("Loading...",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Brew brew) {
    return Dismissible(
      key: ValueKey<String>(brew.id!),
      background: Container(
        color: Colors.red,
      ),
      onDismissed: (DismissDirection direction) async {
        var lastDeletedBrew = await brewBloc.getBrewById(brew.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Brew deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                brewBloc.addBrew(lastDeletedBrew);
              },
            ),
          ),
        );
        // no need to call setState here because the db refresh will do that
        // for us
        brewBloc.deleteBrewById(brew.id!);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[200]!, width: 0.5),
          borderRadius: BorderRadius.circular(5),
        ),
        child: InkWell(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: "${brew.roaster ?? ""}: "),
                              TextSpan(text:  "${brew.blend ?? ""}", style: TextStyle(fontWeight: FontWeight.bold),),
                            ]
                        ),
                      ),),
                      Text("${DateTime.fromMillisecondsSinceEpoch(brew.time ?? 0, isUtc: true).format()}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: "${brew.method}: ${brew.grindSize}"
                              ),
                            ],
                          )
                      )),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: "${brew.water} ${brew.waterMeasurement ?? "g"} "),
                            WidgetSpan(child: Icon(Icons.water)),
                            TextSpan(text: "/ ${brew.dose} ${brew.doseMeasurement ?? "g"}"),
                            WidgetSpan(child: Icon(Icons.coffee)),
                          ],
                        ),
                      ),
                      Text("${Duration(seconds: brew.duration ?? 0).format()}"),
                    ],
                  ),
                ],
              )
          ),
          onTap: () => Navigator.of(context).pushNamed(brewDetails, arguments: brew),
        ),
      ),
    ) ;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _newBrew() {
    Navigator.of(context).pushNamed(newBrew).then((_) => _refresh());
  }

  void _refresh() {
    brewBloc.getBrews();
    setState(() {});
  }

  Widget _buildSettings() {
    return SettingsList(
      sections: [
        SettingsSection(
          title: Text('Brew Defaults'),
          tiles: [
            SettingsTile(
              title: Text('Default Roast Profile'),
              description: Text(sp.getString(PrefKeys.default_roast_profile.name) ?? ''),
              leading: Icon(Icons.sunny),
              onPressed: (context) async {
                await showTextInputDialog(
                  spKey: PrefKeys.default_roast_profile.name,
                  hint: 'Default Roast Profile',
                  items: roastProfiles
                );
                setState(() {});
              },
            ),
            SettingsTile(
              title: Text('Default Brew Method'),
              description: Text(sp.getString(PrefKeys.default_brew_method.name) ?? ''),
              leading: Icon(Icons.coffee_maker),
              onPressed: (context) async {
                await showTextInputDialog(
                    spKey: PrefKeys.default_brew_method.name,
                    hint: 'Default Brew Method',
                    items: brewMethods
                );
                setState(() {});
              },
            ),
            SettingsTile(
              title: Text('Default Grind Size'),
              description: Text(sp.getString(PrefKeys.default_grind_size.name) ?? ''),
              leading: Icon(Icons.grain),
              onPressed: (context) async {
                await showTextInputDialog(
                    spKey: PrefKeys.default_grind_size.name,
                    hint: 'Default Grind Size',
                    items: grindSizes
                );
                setState(() {});
              },
            ),
            SettingsTile(
              title: Text('Default Dose Measurement'),
              description: Text(sp.getString(PrefKeys.default_dose_measurement.name) ?? ''),
              leading: Icon(Icons.scale),
              onPressed: (context) async {
                await showTextInputDialog(
                    spKey: PrefKeys.default_dose_measurement.name,
                    hint: 'Default Dose Measurement',
                    items: doseMeasurements
                );
                setState(() {});
              },
            ),
            SettingsTile(
              title: Text('Default Water Measurement'),
              description: Text(sp.getString(PrefKeys.default_water_measurement.name) ?? ''),
              leading: Icon(Icons.scale),
              onPressed: (context) async {
                await showTextInputDialog(
                    spKey: PrefKeys.default_water_measurement.name,
                    hint: 'Default Water Measurement',
                    items: waterMeasurements
                );
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    brewBloc.dispose();
  }

  Future showTextInputDialog({required String spKey, required String hint, required List<String> items}) async {
    String spValue = sp.getString(spKey) ?? '';
    String _defaultValue = spValue.isNotEmpty ? spValue : items[0];
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, StateSetter _setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField(
                      decoration:
                      InputDecoration(labelText: hint),
                      value: _defaultValue,
                      onChanged: (value) {
                        setState(() {
                          _defaultValue = value.toString();
                        });
                      },
                      items: items
                          .map((String profile) => DropdownMenuItem(
                        value: profile,
                        child: Text(profile),
                      ))
                          .toList()
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  sp.setString(spKey, _defaultValue.trim());
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
