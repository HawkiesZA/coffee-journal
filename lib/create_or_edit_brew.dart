import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'main.dart';
import 'routes.dart';
import 'extensions.dart';
import 'constants.dart';

import 'package:coffee_journal/model/brew.dart';
                    RawAutocomplete<Brew>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (snapshot.hasData) {
                          return snapshot.data.filterUniqueVarietal().where((Brew option) {
                            return option.varietal!.toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        }
                        return List.generate(0, (index) => Brew());
                      },
                      initialValue: TextEditingValue(text: _varietal),
                      displayStringForOption: _displayStringForVarietal,
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
                          decoration: const InputDecoration(labelText: "Varietal"),
                          onChanged: (text) {
                            _varietal = text;
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
                                      _varietal = option.varietal!;
                                    },
                                    child: ListTile(
                                      title: Text(option.varietal!),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
import 'package:coffee_journal/bloc/brew_bloc.dart';

class CreateOrEditBrew extends StatefulWidget {
  CreateOrEditBrew({Key? key}) : super(key: key);

  @override
  CreateOrEditBrewState createState() {
    return CreateOrEditBrewState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class CreateOrEditBrewState extends State<CreateOrEditBrew> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  late final BrewBloc brewBloc;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String _roaster = "";
  String _blend = "";
  String _varietal = "";
  String _selectedRoastProfile = sp.getString(PrefKeys.default_roast_profile.name) ?? roastProfiles[0];
  String _selectedBrewMethod = sp.getString(PrefKeys.default_brew_method.name) ?? brewMethods[0];
  String _selectedGrindSize = sp.getString(PrefKeys.default_grind_size.name) ?? grindSizes[0];
  int _dose = 0;
  String _selectedDoseMeasurement = sp.getString(PrefKeys.default_dose_measurement.name) ?? doseMeasurements[0];
  int _water = 0;
  String _selectedWaterMeasurement = sp.getString(PrefKeys.default_water_measurement.name) ?? waterMeasurements[0];

  @override
  initState() {
    super.initState();
    brewBloc = BrewBloc();
    brewBloc.getBrews();
  }

  @override
  void dispose() {
    super.dispose();
    brewBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    // if this is an edit then this will contain something
    final args = ModalRoute.of(context)!.settings.arguments as Brew?;
    return Scaffold(
        appBar: AppBar(
          title: (args == null) ? Text("New Brew") : Text("Edit Brew"),
        ),
        body: StreamBuilder(
            stream: brewBloc.brews,
            builder:
                (BuildContext context, AsyncSnapshot<List<Brew>> snapshot) {
              return _buildForm(snapshot, args);
            }));
  }

  static String _displayStringForRoaster(Brew option) => option.roaster ?? '';
  static String _displayStringForBlend(Brew option) => option.blend ?? '';

  Widget _buildForm(AsyncSnapshot<List<Brew>> snapshot, Brew? args) {
    if (args != null) {
      _roaster = args.roaster ?? _roaster;
      _blend = args.blend ?? _blend;
      _varietal = args.varietal ?? _varietal;
      _selectedRoastProfile = args.roastProfile ?? _selectedRoastProfile;
      _selectedBrewMethod = args.method ?? _selectedBrewMethod;
      _selectedGrindSize = args.grindSize ?? _selectedGrindSize;
      _dose = args.dose ?? _dose;
      _selectedDoseMeasurement = args.doseMeasurement ?? _selectedDoseMeasurement;
      _water = args.water ?? _water;
      _selectedWaterMeasurement = args.waterMeasurement ?? _selectedWaterMeasurement;
    }
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
                      initialValue: TextEditingValue(text: _roaster),
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
                      initialValue: TextEditingValue(text: _blend),
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
                            .toList()
                    ),
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
                        items: grindSizes
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
                              initialValue: _dose > 0 ? _dose.toString() : "",
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
                              initialValue: _water > 0 ? _water.toString() : "",
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
                    if (args != null) _rating(args),
                    if (args != null) _saveBrewButton(args.id) else _startBrewButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _startBrewButton() => ElevatedButton(
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
  );

  Widget _saveBrewButton(String? id) => ElevatedButton(
    onPressed: () {
      // Validate returns true if the form is valid, or false otherwise.
      if (_formKey.currentState!.validate()) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving Brew')),
        );
        _saveBrew(id);
      }
    },
    child: const Text('Save Brew'),
  );

  Widget _rating(Brew brew) {
    return RatingBar.builder(
      initialRating: brew.rating?.toDouble() ?? 0,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      itemSize: 35,
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) async {
        brew.rating = rating.toInt();
        await brewBloc.updateBrew(brew);
      },
    );
  }

  void _saveBrew(String? id) async {
    final creator = auth.currentUser!.uid;
    var brew = Brew(
      id: id,
      creator: creator,
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
    await brewBloc.updateBrew(brew);
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _startBrew() async {
    final creator = auth.currentUser!.uid;
    var brew = Brew(
      creator: creator,
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
