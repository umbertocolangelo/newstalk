import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/provider/rebuild_provider.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../managers/provider/userEdit_provider.dart';
import '../../model/globals.dart';

class CategorySelectionProfile extends StatefulWidget {
  final String userID;

  const CategorySelectionProfile({super.key, required this.userID});

  @override
  _CategorySelectionProfileState createState() =>
      _CategorySelectionProfileState();
}

class _CategorySelectionProfileState extends State<CategorySelectionProfile> {
  UserController userController = UserController();

  final List<String> categories = [
    'Tutto',
    'Attualità',
    'Sport',
    'Intrattenimento',
    'Salute',
    'Economia',
    'Tecnologia'
  ];

  Set<String> selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _loadUserCategories();
  }

  Future<void> _loadUserCategories() async {
    Set<String> userCategories =
        await userController.getSelectedCategorybyUser(widget.userID);
    setState(() {
      selectedCategories = userCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Sezione Seleziona/Deseleziona Tutto
            ListTile(
              leading: Icon(
                selectedCategories.length == categories.length
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: selectedCategories.length == categories.length
                    ? Palette.red
                    : Palette.grey,
              ),
              title:  Text("Seleziona/Deseleziona Tutto",style:TextStyle(fontSize: 16.sp)),
              onTap: _toggleAllCategories,
            ),
            // Sezione delle categorie
            Flexible(
              child: Column(
                children: [
                  ...categories.map((category) {
                    bool isSelected = selectedCategories.contains(category);
                    return Expanded(
                      child: Padding(
                        padding:  EdgeInsets.only(left: 16.sp),
                        child: ListTile(
                          leading: Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isSelected ? Palette.red : Palette.grey,
                          ),
                          title: Text(category, style: TextStyle(fontSize: 16.sp),),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedCategories.remove(category);
                              } else {
                                selectedCategories.add(category);
                              }
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            // Bottone per salvare
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.sp, vertical: 4.sp),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedCategories.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Seleziona almeno una categoria!')),
                      );
                    } else {
                      _saveCategories();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.beige,
                    foregroundColor: Palette.black,
                    side: BorderSide(color: Palette.black, width: 2.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:  Text("Salva categorie", style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleAllCategories() {
    setState(() {
      if (selectedCategories.length == categories.length) {
        selectedCategories.clear();
      } else {
        selectedCategories.addAll(categories);
      }
    });
  }

  void _saveCategories() async {
    await userController.setSelctedCategorybyUser(
        Globals.instance.userUid.toString(), selectedCategories.toList());
    Provider.of<UserEditProvider>(context, listen: false).selectedCategory =
        selectedCategories.first;
    Provider.of<UserEditProvider>(context, listen: false)
        .setSelectedCategories(selectedCategories);
    Provider.of<RebuildNotifier>(context, listen: false).rebuild();
    // Show snackbar
     var snackBar = SnackBar(content: Text('Categorie salvate correttamente!', style: TextStyle(fontSize: 16.sp)));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
