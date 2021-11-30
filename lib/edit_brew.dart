import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'package:coffee_journal/bloc/brew_bloc.dart';

import 'package:coffee_journal/model/brew.dart';

class EditBrew extends StatefulWidget {
  EditBrew({Key? key}) : super(key: key);

  final BrewBloc brewBloc = BrewBloc();

  @override
  EditBrewState createState() {
    return EditBrewState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class EditBrewState extends State<EditBrew> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() async {
    super.dispose();
    widget.brewBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Brew"),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    final args = ModalRoute.of(context)!.settings.arguments as Brew;
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
                    TextFormField(
                      initialValue: args.roaster,
                      decoration: const InputDecoration(
                          labelText: "Roaster"
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter the roaster's name";
                        }
                        return null;
                      },
                      onChanged: (text) {
                        args.roaster = text;
                      },
                    ),
                    TextFormField(
                      initialValue: args.blend,
                      decoration: const InputDecoration(
                          labelText: "Blend"
                      ),
                      onChanged: (text) {
                        args.blend = text;
                      },
                    ),
                    DropdownButtonFormField(
                        decoration: const InputDecoration(
                            labelText: "Roast Profile"
                        ),
                        value: args.roastProfile,
                        onChanged: (value) {
                          setState(() {
                            args.roastProfile = value.toString();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            args.roastProfile = value.toString();
                          });
                        },
                        items: roastProfiles
                            .map((String profile) => DropdownMenuItem(
                          value: profile,
                          child: Text (profile),
                        )).toList()
                    ),
                    DropdownButtonFormField(
                        decoration: const InputDecoration(
                            labelText: "Brew Method"
                        ),
                        value: args.method,
                        onChanged: (value) {
                          setState(() {
                            args.method = value.toString();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            args.method = value.toString();
                          });
                        },
                        items: brewMethods
                            .map((String profile) => DropdownMenuItem(
                          value: profile,
                          child: Text (profile),
                        )).toList()
                    ),
                    DropdownButtonFormField(
                        decoration: const InputDecoration(
                            labelText: "Grind Size"
                        ),
                        value: args.grindSize,
                        onChanged: (value) {
                          setState(() {
                            args.grindSize = value.toString();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            args.grindSize = value.toString();
                          });
                        },
                        items: grindSize
                            .map((String profile) => DropdownMenuItem(
                          value: profile,
                          child: Text (profile),
                        )).toList()
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
                                initialValue: args.dose.toString(),
                                decoration: const InputDecoration(
                                    labelText: "Dose"
                                ),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Enter the amount of coffee used";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                onChanged: (text) {
                                  args.dose = int.parse(text);
                                },
                              ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  labelText: "Measurement"
                              ),
                              value: args.doseMeasurement,
                              onChanged: (value) {
                                setState(() {
                                  args.doseMeasurement = value.toString();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  args.doseMeasurement = value.toString();
                                });
                              },
                              items: doseMeasurements
                                  .map((String profile) => DropdownMenuItem(
                                value: profile,
                                child: Text (profile),
                              )).toList()
                          ),
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
                              initialValue: args.water.toString(),
                              decoration: const InputDecoration(
                                  labelText: "Water"
                              ),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter the amount of water used";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (text) {
                                args.water = int.parse(text);
                            },
                          ),
                        ),),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField(
                              decoration: const InputDecoration(
                                  labelText: "Measurement"
                              ),
                              value: args.waterMeasurement,
                              onChanged: (value) {
                                setState(() {
                                  args.waterMeasurement = value.toString();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  args.waterMeasurement = value.toString();
                                });
                              },
                              items: waterMeasurements
                                  .map((String profile) => DropdownMenuItem(
                                value: profile,
                                child: Text (profile),
                              )).toList()
                          ),
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
                            const SnackBar(content: Text('Saving Brew')),
                          );
                          _saveBrew(args);
                        }
                      },
                      child: const Text('Save Brew'),
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

  void _saveBrew(Brew brew) async {
    await widget.brewBloc.updateBrew(brew);
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}