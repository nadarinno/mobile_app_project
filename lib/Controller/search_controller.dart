
import 'package:flutter/material.dart';
import '../logic/search_logic.dart';

class CustomSearchController {
  final SearchLogic _logic = SearchLogic();
  final TextEditingController textController = TextEditingController();
  List<String> suggestions = [];

  Future<void> updateSuggestions(String query) async {
    final newSuggestions = await _logic.fetchSuggestions(query.trim());
    suggestions = newSuggestions;
  }

  void clearSearch() {
    textController.clear();
    suggestions = [];
  }

  void selectSuggestion(String suggestion, Function(String) onSearch) {
    textController.text = suggestion;
    suggestions = [];
    onSearch(suggestion);
  }

  void dispose() {
    textController.dispose();
  }
}