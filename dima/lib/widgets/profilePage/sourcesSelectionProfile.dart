import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/provider/rebuild_provider.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../managers/provider/userEdit_provider.dart';

class SourceSelectionProfile extends StatefulWidget {
  final String userID;

  const SourceSelectionProfile({super.key, required this.userID});

  @override
  _SourceSelectionProfileState createState() => _SourceSelectionProfileState();
}

class _SourceSelectionProfileState extends State<SourceSelectionProfile> {
  UserController userController = UserController();

  final Map<String, String> sources = {
    "Gazzeta dello Sport": "gazzetta_sport",
    "Il Fatto Quotidiano": "fatto_quotidiano",
    "Corriere ddella Sera": "della_sera",
    "Il Giornale": "il_giornale",
    "Il Foglio": "foglio",
    "Il Sole24": "sole24",
    "Fanpage": "fanpage",
    "Libero": "libero",
    "SkyTG24": "sky_tg",
    "Ansa": "ansa",
    "Microbiolo": "micro_bio",
    "Donna Moderna": "donna_moderna"
  };

  Set<String> selectedSources = {};

  @override
  void initState() {
    super.initState();
    _loadUserSources();
  }

  Future<void> _loadUserSources() async {
    Set<String> userSources =
        await userController.getSelectedSourcesbyUser(widget.userID);
    setState(() {
      selectedSources = userSources;
    });
  }

  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(
            selectedSources.length == sources.length
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            color: selectedSources.length == sources.length
                ? Palette.red
                : Palette.grey,
          ),
          title: Text("Seleziona/Deselziona Tutto"),
          onTap: _toggleAllSources,
        ),
        ...sources.entries.map((entry) {
          bool isSelected = selectedSources.contains(entry.value);
          return Padding(
            padding:  EdgeInsets.only(left: 16.sp),
            child: ListTile(
              leading: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? Palette.red : Palette.grey,
              ),
              title: Text(entry.key),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedSources.remove(entry.value);
                  } else {
                    selectedSources.add(entry.value);
                  }
                });
              },
            ),
          );
        }).toList(),
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (selectedSources.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Seleziona almeno una fonte!')),
                    );
                  } else {
                    _saveSources();
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
                child: const Text("Salva fonti"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleAllSources() {
    setState(() {
      if (selectedSources.length == sources.length) {
        selectedSources.clear();
      } else {
        selectedSources.addAll(sources.values);
      }
    });
  }

  void _saveSources() async {
    await userController.setSelctedSourcesbyUser(
        Globals.instance.userUid.toString(), selectedSources.toList());
    Provider.of<UserEditProvider>(context, listen: false)
        .setSelectedSources(selectedSources);
    Provider.of<RebuildNotifier>(context, listen: false).rebuild();
    Provider.of<ArticleController>(context, listen: false).clearArticles();

    // Show snackbar
    final snackBar = SnackBar(content: Text('Fonti salvate correttamente!'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
