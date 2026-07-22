import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tokens.dart';
import '../theme/palette.dart';

class DebouncedSearchBar extends StatefulWidget {
  final bool isTablet;
  final String hintText;
  final Function(String) onChanged;
  final Duration debounceDuration;

  const DebouncedSearchBar({
    super.key,
    required this.isTablet,
    required this.onChanged,
    this.hintText = 'Search...',
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  @override
  State<DebouncedSearchBar> createState() => _DebouncedSearchBarState();
}

class _DebouncedSearchBarState extends State<DebouncedSearchBar> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.kWhite,
        borderRadius: BorderRadius.circular(widget.isTablet ? 14 : 12),
        border: Border.all(color: AppTokens.brandMid.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppTokens.brandGradientStart),
          hintText: widget.hintText,
          hintStyle: GoogleFonts.lato(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: widget.isTablet ? 16 : 14,
            horizontal: 12,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
            onPressed: () {
              _controller.clear();
              widget.onChanged('');
            },
          ),
        ),
      ),
    );
  }
}
