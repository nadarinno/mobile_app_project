import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const CustomSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {

  final TextEditingController _controller = TextEditingController();
  final List<String> _suggestions = [
    'Jeans',
    'Wide-leg Pants',
    'Charleston Pants',
    'Sports Shoes',
    'Formal Shoes',
    'Backpack'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMatches = _controller.text.isNotEmpty &&
        _suggestions.any((s) => s.toLowerCase().contains(_controller.text.toLowerCase()));

    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(

            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),

            ),
            filled: true,
            fillColor: const Color(0xFFFFFDF6),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {});
              },
            )
                : null,
          ),
          onChanged: (value) => setState(() {}),
          onSubmitted: widget.onSearch,
        ),
        if (_controller.text.isNotEmpty)
          _buildSuggestionsWidget(hasMatches),
      ],
    );
  }

  Widget _buildSuggestionsWidget(bool hasMatches) {
    return hasMatches
        ? Column(children: _buildSuggestions())
        : const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'No matching items found',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  List<Widget> _buildSuggestions() {
    final query = _controller.text.toLowerCase();
    return _suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .map((suggestion) => ListTile(
      title: Text(suggestion),
      onTap: () {
        _controller.text = suggestion;
        widget.onSearch(suggestion);
      },
    ))
        .toList();
  }
}