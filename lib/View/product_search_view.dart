import 'package:flutter/material.dart';
import '../Logic/product_search_logic.dart';


class ProductSearchView extends SearchDelegate {
  final ProductSearchLogic logic;

  ProductSearchView(this.logic) : super();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return logic.buildSearchResults(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return logic.buildSearchResults(context, query);
  }
}