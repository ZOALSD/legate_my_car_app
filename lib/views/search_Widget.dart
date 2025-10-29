import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:legate_my_car/viewmodels/car_viewmodel.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({
    super.key,
    required this.searchController,
    required this.viewModel,
  });

  final TextEditingController searchController;
  final CarViewModel viewModel;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild to show/hide clear button
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        autofocus: false,
        focusNode: _focusNode,
        controller: widget.searchController,
        style: const TextStyle(fontSize: 16),
        onChanged: (value) {
          widget.viewModel.searchCars(value);
        },
        decoration: InputDecoration(
          hintText: "SEARCH_HINT".tr,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.search, color: Colors.grey, size: 20),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(width: 0.5),
          ),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    widget.searchController.clear();
                    widget.viewModel.clearSearch();
                    setState(() {
                      // Update UI after clearing
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
