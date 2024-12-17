import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/newsFeed/newsFeedForCategory.dart';
import 'package:dima/widgets/newsFeed/newsFeedSelectionCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:provider/provider.dart';
import '../managers/provider/userEdit_provider.dart';
import '../model/globals.dart';

class NewsFeedPage extends StatefulWidget {
  final Map<String, int> swiperIndex;
  const NewsFeedPage({super.key, required this.swiperIndex});

  @override
  NewsFeedPageState createState() => NewsFeedPageState();
}

class NewsFeedPageState extends State<NewsFeedPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<NewsForCategoryState> _newsFeedKey = GlobalKey();
  final SwiperController swiperController = SwiperController();
  final UserController userController = UserController();
  Set<String> selectedCategories = {};

  String _selectedCategory = 'Tutto';
  bool _isLoading = true; // State variable to track initialization

  List<String> categories = [
    'Tutto',
    'Attualità',
    'Sport',
    'Intrattenimento',
    'Salute',
    'Economia',
    'Tecnologia',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeUserData();
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _initializeUserData() async {
    if (Globals.instance.userUid != null) {
      final Set<String> userCategories = await userController
          .getSelectedCategorybyUser(Globals.instance.userUid.toString());
      final Set<String> userSources = await userController
          .getSelectedSourcesbyUser(Globals.instance.userUid.toString());

      if (mounted) {
        Provider.of<UserEditProvider>(context, listen: false)
            .setSelectedCategories(userCategories);
        Provider.of<UserEditProvider>(context, listen: false)
            .setSelectedSources(userSources);

        setState(() {
          _selectedCategory = categories.firstWhere(
            (category) => userCategories.contains(category),
            orElse: () => 'Tutto',
          );
        });
      }
    } else {
      final Set<String> defaultCategories = {
        'Tutto',
        'Attualità',
        'Sport',
        'Intrattenimento',
        'Salute',
        'Economia',
        'Tecnologia',
      };
      final Set<String> defaultSources = {
        "gazzetta_sport",
        "fatto_quotidiano",
        "della_sera",
        "il_giornale",
        "foglio",
        "sole24",
        "fanpage",
        "libero",
        "sky_tg",
        "ansa",
        "micro_bio",
        "donna_moderna"
      };

      if (mounted) {
        Provider.of<UserEditProvider>(context, listen: false)
            .setSelectedCategories(defaultCategories);
        Provider.of<UserEditProvider>(context, listen: false)
            .setSelectedSources(defaultSources);
        setState(() {
          _selectedCategory = "Tutto";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);

    return Scaffold(
      appBar: AppBar(
          title: Text('News',
              style: TextStyle(
                color: Palette.red,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              )),
          backgroundColor: Palette.offWhite,
          foregroundColor: Palette.black,
          centerTitle: true),
      body: _isLoading
          ? Container(
              color: Palette.offWhite,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                ),
              ),
            )
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.1,
                      child: CategorySelectionWidget(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _onCategorySelected,
                        heightNewsFeed: constraints.maxHeight,
                        userSelectedCategories: Provider.of<UserEditProvider>(
                                context,
                                listen: false)
                            .selectedCategories,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Palette.offWhite,
                        padding:  EdgeInsets.only(top: 5.sp, bottom: 0),
                        child: NewsFeedForCategory(
                          key: _newsFeedKey,
                          controller: _scrollController,
                          category: _selectedCategory,
                          sources: Provider.of<UserEditProvider>(context,
                                  listen: false)
                              .selectedSources,
                          swiperIndex: widget.swiperIndex,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _onCategorySelected(String category) {
    if (category != _selectedCategory) {
      setState(() {
        _selectedCategory = category;
      });
    }
  }
}
