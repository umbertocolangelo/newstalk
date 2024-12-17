import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBarSearching extends StatefulWidget {
  final Function(String, String) onSearch;
  final String selectedPanel;
  final List<String> categories = [
    'Tutto',
    'Attualità',
    'Sport',
    'Intrattenimento',
    'Salute',
    'Business',
    'Tecnologia'
  ];

  SearchBarSearching(
      {super.key, required this.onSearch, required this.selectedPanel});

  @override
  _SearchBarSearchingState createState() => _SearchBarSearchingState();
}

class _SearchBarSearchingState extends State<SearchBarSearching> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String selectedCategory = "Tutto";
  String query = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.sp),
        child: FocusScope(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (value) {
              setState(() {
                query =
                    value; // Update the query variable whenever text changes
              });
            },
            onSubmitted: (value) {
              widget.onSearch(query,
                  selectedCategory.toLowerCase()); // Use query directly here
            },
            decoration: InputDecoration(
              hintText: 'Cerca...',
              hintStyle: TextStyle(color: Palette.black.withOpacity(0.8)),
              fillColor: Colors.white,
              filled: true,
              prefixIcon: const Icon(Icons.search, color: Palette.red),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCategory,
                    style: TextStyle(color: Palette.black.withOpacity(0.8)),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down, color: Palette.black),
                    onSelected: (value) {
                      setState(() {
                        selectedCategory = value;
                        widget.onSearch(
                            query,
                            selectedCategory
                                .toLowerCase()); // Use updated query and selectedCategory
                      });
                    },
                    itemBuilder: (BuildContext context) {
                        return widget.categories.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      }
                  )
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Palette.black, width: 2.sp),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Palette.black, width: 2.sp),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Palette.grey, width: 2.sp),
              ),
            ),
          ),
        ));
  }
}
