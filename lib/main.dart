import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:coffee_journal/bloc/brew_bloc.dart';
import 'package:coffee_journal/brew_details.dart';
import 'package:coffee_journal/edit_brew.dart';
import 'package:coffee_journal/model/brew.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'main_search_delegate.dart';
import 'new_brew.dart';
import 'routes.dart';
import 'brew_in_progress.dart';
import 'extensions.dart';

import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        brewDetailsRoute: (BuildContext context) => BrewDetails(),
        newBrewRoute: (BuildContext context) => NewBrew(),
        brewInProgress: (BuildContext context) => BrewInProgress(),
        editBrew: (BuildContext context) => EditBrew(),
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

  void search(String searchString) {
    developer.log("Searching");
    brewBloc.getBrews(query: searchString);
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
      key: ValueKey<int>(brew.id!),
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
          onTap: () => Navigator.of(context).pushNamed(brewDetailsRoute, arguments: brew),
        ),
      ),
    ) ;
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
      body: _buildList(),
      floatingActionButton: fabIsVisible ? FloatingActionButton(
        onPressed: _newBrew,
        tooltip: 'New Brew',
        child: Icon(Icons.coffee),
      ) : null,
    );
  }

  void _newBrew() {
    Navigator.of(context).pushNamed(newBrewRoute).then((_) => _refresh());
  }

  void _refresh() {
    brewBloc.getBrews();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    brewBloc.dispose();
  }
}
