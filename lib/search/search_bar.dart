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

  static const Color burgundy = Color(0xFF561C24);

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
            hintStyle: TextStyle(color: burgundy.withAlpha(150)), // لون نص التلميح برجي
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
            fillColor: const Color(0xFFFFFDF6),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: burgundy),
              onPressed: () {
                _controller.clear();
                setState(() {});
              },
            )
                : null,
          ),
          style: const TextStyle(color: Color(0xFF561C24)),
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
          color: Color(0xFF561C24),
          fontSize: 16,
        ),
      ),
    );
  }

  List<Widget> _buildSuggestions() {
    final query = _controller.text.toLowerCase();
    return _suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query))
        .map(
          (suggestion) => ListTile(
        title: Text(
          suggestion,
          style: const TextStyle(color: Color(0xFF561C24)),
        ),
        onTap: () {
          _controller.text = suggestion;
          widget.onSearch(suggestion);
          setState(() {});
        },
      ),
    )
        .toList();
  }
}
