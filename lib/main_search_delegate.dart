import 'package:flutter/material.dart';
import 'package:coffee_journal/model/brew.dart';

class MainSearchDelegate extends SearchDelegate {
  List<Brew> brews = List.empty();
  List<String> searchTerms = [];

  MainSearchDelegate(this.brews) {
    for (var brew in brews) {
      var roaster = brew.roaster;
      var blend = brew.blend;
      var method = brew.method;
      var rating = brew.rating;
      if (roaster != null && !searchTerms.contains(roaster)) {
        searchTerms.add(roaster);
      }
      if (blend != null && !searchTerms.contains(blend)) {
        searchTerms.add(blend);
      }
      if (method != null && !searchTerms.contains(method)) {
        searchTerms.add(method);
      }
      var stringRating = rating?.toString();
      if (stringRating != null && !searchTerms.contains(stringRating)) {
        searchTerms.add(stringRating);
      }
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var term in searchTerms) {
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(term);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () => close(context, query)
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var term in searchTerms) {
      if (term.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(term);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () => close(context, result)
        );
      },
    );
  }
}