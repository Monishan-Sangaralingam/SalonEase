import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    this.onChanged,
    this.controller,
    this.hintText = 'Search',
    this.onSortTap,
    this.onFilterTap,
  });

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onSortTap;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.start,
                cursorHeight: 25,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.pink),
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  hintText: hintText,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onSortTap,
            borderRadius: BorderRadius.circular(45),
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(45),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: Colors.pink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Icon(Icons.filter_alt_outlined, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
