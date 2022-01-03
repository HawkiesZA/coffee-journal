import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes.dart';
import 'extensions.dart';
import 'constants.dart';

import 'package:coffee_journal/model/brew.dart';
import 'package:coffee_journal/bloc/brew_bloc.dart';

class NewBrew extends StatefulWidget {
  NewBrew({Key? key}) : super(key: key);

  @override
  NewBrewState createState() {
    return NewBrewState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class NewBrewState extends State<NewBrew> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  late final BrewBloc brewBloc;
  final _formKey = GlobalKey<FormState>();

  String _roaster = "";
  String _blend = "";
  String _selectedRoastProfile = "Light";
  String _selectedBrewMethod = "Aeropress";
  String _selectedGrindSize = "Coarse";
  int _dose = 0;
  String _selectedDoseMeasurement = "g";
  int _water = 0;
  String _selectedWaterMeasurement = "g";

  @override
  initState() {
    super.initState();
    brewBloc = BrewBloc();
  }

  @override
  void dispose() {
    super.dispose();
    brewBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        appBar: AppBar(
          title: Text("New Brew"),
        ),
        body: StreamBuilder(
            stream: brewBloc.brews,
            builder:
                (BuildContext context, AsyncSnapshot<List<Brew>> snapshot) {
              return _buildForm(snapshot);
            }));
  }

  static String _displayStringForRoaster(Brew option) => option.roaster ?? '';
  static String _displayStringForBlend(Brew option) => option.blend ?? '';

  Widget _buildForm(AsyncSnapshot<List<Brew>> snapshot) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RawAutocomplete<Brew>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (snapshot.hasData) {
                          return snapshot.data.filterUniqueRoaster().where((Brew option) {
                            return option.roaster!.toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        }
                        return List.generate(0, (index) => Brew());
                      },
                      displayStringForOption: _displayStringForRoaster,
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                          decoration:
                              const InputDecoration(labelText: "Roaster"),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter the roaster's name";
                            }
                            return null;
                          },
                          onChanged: (text) {
                            _roaster = text;
                          },
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<Brew> onSelected,
                          Iterable<Brew> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              height: 120.0,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Brew option = options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                      _roaster = option.roaster!;
                                    },
                                    child: ListTile(
                                      title: Text(option.roaster!),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    RawAutocomplete<Brew>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (snapshot.hasData) {
                          return snapshot.data.filterUniqueBlend().where((Brew option) {
                            return option.blend!.toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        }
                        return List.generate(0, (index) => Brew());
                      },
                      displayStringForOption: _displayStringForBlend,
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                          decoration: const InputDecoration(labelText: "Blend"),
                          onChanged: (text) {
                            _blend = text;
                          },
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          AutocompleteOnSelected<Brew> onSelected,
                          Iterable<Brew> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: SizedBox(
                              height: 120.0,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Brew option = options.elementAt(index);
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                      _blend = option.blend!;
                                    },
                                    child: ListTile(
                                      title: Text(option.blend!),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    DropdownButtonFormField(
                        decoration:
                            const InputDecoration(labelText: "Roast Profile"),
                        value: _selectedRoastProfile,
                        onChanged: (value) {
                          setState(() {
                            _selectedRoastProfile = value.toString();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _selectedRoastProfile = value.toString();
                          });
                        },
                        items: roastProfiles
                            .map((String profile) => DropdownMenuItem(
                                  value: profile,
                                  child: Text(profile),
                                ))
                            .toList()),
                    DropdownButtonFormField(
                        decoration:
                            const InputDecoration(labelText: "Brew Method"),
                        value: _selectedBrewMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedBrewMethod = value.toString();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _selectedBrewMethod = value.toString();
                          });
                        },
                        items: brewMethods
                            .map((String profile) => DropdownMenuItem(
                                  value: profile,
                                  child: Text(profile),
                                ))
                            .toList()),
                    DropdownButtonFormField(
                        decoration:
                            const InputDecoration(labelText: "Grind Size"),
                        value: _selectedGrindSize,
                        onChanged: (value) {
                          setState(() {
                            _selectedGrindSize = value.toString();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _selectedGrindSize = value.toString();
                          });
                        },
                        items: grindSize
                            .map((String profile) => DropdownMenuItem(
                                  value: profile,
                                  child: Text(profile),
                                ))
                            .toList()),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: "Dose"),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter the amount of coffee used";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (text) {
                                _dose = int.parse(text);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  labelText: "Measurement"),
                              value: _selectedDoseMeasurement,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDoseMeasurement = value.toString();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _selectedDoseMeasurement = value.toString();
                                });
                              },
                              items: doseMeasurements
                                  .map((String profile) => DropdownMenuItem(
                                        value: profile,
                                        child: Text(profile),
                                      ))
                                  .toList()),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: "Water"),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter the amount of water used";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (text) {
                                _water = int.parse(text);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  labelText: "Measurement"),
                              value: _selectedWaterMeasurement,
                              onChanged: (value) {
                                setState(() {
                                  _selectedWaterMeasurement = value.toString();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _selectedWaterMeasurement = value.toString();
                                });
                              },
                              items: waterMeasurements
                                  .map((String profile) => DropdownMenuItem(
                                        value: profile,
                                        child: Text(profile),
                                      ))
                                  .toList()),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting Brew'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                          _startBrew();
                        }
                      },
                      child: const Text('Start Brewing'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startBrew() async {
    var brew = Brew(
      roaster: _roaster.trim(),
      blend: _blend.trim(),
      roastProfile: _selectedRoastProfile,
      method: _selectedBrewMethod,
      grindSize: _selectedGrindSize,
      dose: _dose,
      doseMeasurement: _selectedDoseMeasurement,
      water: _water,
      waterMeasurement: _selectedWaterMeasurement,
      time: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    Navigator.of(context).pushNamed(brewInProgress, arguments: brew);
  }
}
