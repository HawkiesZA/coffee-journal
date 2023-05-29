import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_journal/model/brew.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class BrewNotFoundException implements Exception {
  String id;
  BrewNotFoundException(this.id);
  String errMsg() => "No brew found for $id";
}

class BrewDao {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  static const prod_collection = "brews";
  static const dev_collection = "dev_brews";
  late final collection;

  BrewDao() {
    if (kDebugMode) {
      collection = dev_collection;
    } else {
      collection = prod_collection;
    }
  }

  Future<void> createBrew(Brew brew) async {
    developer.log("Creating brew");
    return db.collection(collection).doc().set(brew.toDatabaseJson());
  }

  Future<Brew> getBrewById(String id) async {
    developer.log("Get brew $id");
    final brewDoc = await db.collection(collection).doc(id).get();
    if (brewDoc.exists) {
      final brew = brewDoc.data() as Map<String, dynamic>;
      brew['id'] = brewDoc.id;
      return Brew.fromDatabaseJson(brew);
    } else {
      throw BrewNotFoundException(id);
    }
  }

  Future<Brew> getBrewByRoasterAndBlend(String? roaster, String? blend) async {
    developer.log("Get brew $roaster, $blend");
    final creator = auth.currentUser!.uid;
    final dbBrew = await db.collection(collection)
        .where(Filter.and(
        Filter("creator", isEqualTo: creator),
        Filter("roaster", isEqualTo: roaster),
        Filter("blend", isEqualTo: blend)
    ))
        .orderBy("time", descending: true)
        .limit(1)
        .get();

    final brewDoc = dbBrew.docs.first;
    final brew = brewDoc.data();
    brew['id'] = brewDoc.id;

    return Brew.fromDatabaseJson(brew);
  }

  Future<List<Brew>> getBrews() async {
    developer.log("Getting all brews");
    final creator = auth.currentUser!.uid;
    final dbBrews = await db.collection(collection)
        .where("creator", isEqualTo: creator).get();

    List<Map<String, dynamic>> brewData = dbBrews.docs.map((doc) {
      final brew = doc.data();
      brew['id'] = doc.id;
      return brew;
    }).toList();

    List<Brew> brews = brewData.isNotEmpty
        ? brewData.map((item) => Brew.fromDatabaseJson(item)).toList()
        : [];
    return brews;
  }

  Future<List<Brew>> searchBrews({ required String query }) async {
    developer.log("Searching brews with query: $query");
    final creator = auth.currentUser!.uid;
    final dbBrews = await db.collection(collection)
        .where("creator", isEqualTo: creator)
        .where(Filter.or(
          Filter("roaster", isEqualTo: query),
          Filter("blend", isEqualTo: query),
          Filter("method", isEqualTo: query),
          Filter("rating", isEqualTo: query),
        ))
        .orderBy("time", descending: true)
        .get();

    List<Map<String, dynamic>> brewData = dbBrews.docs.map((doc) {
      final brew = doc.data();
      brew['id'] = doc.id;
      return brew;
    }).toList();

    List<Brew> brews = brewData.isNotEmpty
        ? brewData.map((item) => Brew.fromDatabaseJson(item)).toList()
        : [];
    return brews;
  }

  Future<void> updateBrew(Brew brew) async {
    developer.log("Updating brew ${brew.id}");
    return db.collection(collection).doc(brew.id).set(brew.toDatabaseJson());
  }

  Future<void> deleteBrew(String id) async {
    developer.log("Deleting brew $id");
    return db.collection(collection).doc(id).delete();
  }
}