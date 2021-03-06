import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'routes.dart';

import 'model/brew.dart';
import 'extensions.dart';

class BrewDetails extends StatelessWidget {
  BrewDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Brew;
    return Scaffold(
        appBar: AppBar(
          title: Text("Details for ${args.roaster}"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: IconButton(
                icon: Icon(Icons.share, size: 24.0,),
                onPressed: () {
                  Share.share(args.toString());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: IconButton(
                icon: Icon(Icons.border_color_outlined, size: 24.0,),
                onPressed: () {
                  Navigator.of(context).pushNamed(editBrew, arguments: args);
                },
              ),
            )
          ],
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[200]!, width: 0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "${args.blend}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),

                          ]
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("roasted ${args.roastProfile} by ${args.roaster}")
                            ]
                          ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${args.dose} ${args.doseMeasurement} ${args.grindSize} ground brewed with")
                            ]
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${args.water} ${args.waterMeasurement} water for")
                            ]
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${Duration(seconds: args.duration ?? 0).strFormat()}")
                            ]
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${args.method} at")
                            ]
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("${DateTime.fromMillisecondsSinceEpoch(args.time ?? 0, isUtc: true).format()}")
                            ]
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RatingBarIndicator(
                                rating: args.rating?.toDouble() ?? 0,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemPadding: EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0),
                                itemSize: 25,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              )
                            ]
                        ),
                      ]
                    )
                  )
                ),
            ),
          ),
        )
    );
  }
}
