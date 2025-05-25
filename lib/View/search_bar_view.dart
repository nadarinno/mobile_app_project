// views/search_bar_view.dart
import 'package:flutter/material.dart';
import '../Controller/search_controller.dart';



class SearchBarView extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarView({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchBarView> createState() => _SearchBarViewState();
}

class _SearchBarViewState extends State<SearchBarView> {
  static const Color burgundy = Color(0xFF561C24);
  static const Color lightBurgundy = Color(0xFFFFFDF6);
  final CustomSearchController _controller = CustomSearchController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller.textController,
          decoration: InputDecoration(
            hintText: 'ابحث...',
            hintStyle: TextStyle(color: burgundy.withAlpha(150)),
            prefixIcon: const Icon(Icons.search, color: burgundy),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: burgundy),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: burgundy),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: burgundy, width: 2),
            ),
            filled: true,
            fillColor: lightBurgundy,
            suffixIcon: _controller.textController.text.trim().isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: burgundy),
              onPressed: () {
                setState(() {
                  _controller.clearSearch();
                });
              },
            )
                : null,
          ),
          style: const TextStyle(color: burgundy),
          onChanged: (value) async {
            await _controller.updateSuggestions(value);
            setState(() {});
          },
          onSubmitted: widget.onSearch,
        ),
        if (_controller.textController.text.trim().isNotEmpty)
          _controller.suggestions.isNotEmpty
              ? Column(
            children: _controller.suggestions
                .map(
                  (s) => ListTile(
                title: Text(s, style: const TextStyle(color: burgundy)),
                onTap: () {
                  setState(() {
                    _controller.selectSuggestion(s, widget.onSearch);
                  });
                },
              ),
            )
                .toList(),
          )
              : const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'لا توجد عناصر مطابقة',
              style: TextStyle(color: burgundy, fontSize: 16),
            ),
          ),
      ],
    );
  }
}