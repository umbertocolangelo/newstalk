import 'package:dima/model/globals.dart';
import 'package:dima/utils/no_scroll_up_physics.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/model/community.dart';
import 'package:dima/model/user.dart';
import '../utils/login_prompt.dart';

import '../widgets/community/communityCategorySelection.dart';
import '../widgets/community/communityListOrSwiper.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  _CommunityFeedPageState createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  String _selectedCategory = 'Tutto';
  List<Community> _communities = [];
  final Map<String, User> _admins = {};
  bool _isFetchingInitialData = false;
  bool _isLoadingMore = false;
  bool _isListView = false;
  bool _isLoggedIn = true;
  final SwiperController _swiperController = SwiperController();
  final UserController userController = new UserController();
  Set<String> selectedCategories = {};
  bool _initialized = false;

  final Set<String> categories= {
    'Tutto',
    'Attualità',
    'Sport',
    'Intrattenimento',
    'Salute',
    'Economia',
    'Tecnologia',
  };

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    if (Globals.instance.userUid != null) {
      _loadUserCategories();
    } else {
      _isLoggedIn = false;
    }
  }

  Future<void> _loadUserCategories() async {
    Set<String> userCategories = await userController
        .getSelectedCategorybyUser(Globals.instance.userUid.toString());
    setState(() {
      selectedCategories = userCategories;
      _selectedCategory = categories.firstWhere(
            (category) => userCategories.contains(category),
            orElse: () => 'Tutto',
          );
    });
  }

  void _loadMoreCommunities() async {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      await Future.delayed(
          const Duration(seconds: 2)); // Simulate network delay
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _fetchInitialData() async {
    setState(() => _isFetchingInitialData = true);
    var communities = await CommunityController().fetchCommunities();
    var adminIds = communities.map((community) => community.adminId).toSet();
    var adminFetches = <Future>[];
    for (var id in adminIds) {
      adminFetches.add(UserController().getUserById(id));
    }
    var admins = await Future.wait(adminFetches);
    if (mounted) {
      setState(() {
        _communities = communities;
        for (var admin in admins) {
          _admins[admin.id] = admin;
        }
        _isFetchingInitialData = false;
        _initialized = true;
      });
    }
  }  

  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);

    _fetchInitialData();

    if (!_isLoggedIn) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return loginPrompt(height: constraints.maxHeight * 0.5, width: constraints.maxWidth);
        });
    }
    if (!_initialized) {
      return Container(
        color: Palette.offWhite,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title:  Text('Community',
            style: TextStyle(
              color: Palette.red,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const NoScrollUpPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: CommunityDiscoveryHeader(
                isListView: _isListView,
                onListViewSelected: () {
                  setState(() {
                    _isListView = true;
                  });
                },
                onSwiperViewSelected: () {
                  setState(() {
                    _isListView = false;
                  });
                },
              ),
            ),
            SliverToBoxAdapter(
              child: CommunityCategorySelection(
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
                userSelectedCategories: selectedCategories,
              ),
            ),
            SliverFillRemaining(
              child: CommunityListOrSwiper(
                isListView: _isListView,
                communities: _getFilteredCommunities(),
                isLoadingMore: _isLoadingMore,
                admins: _admins,
                onLoadMore: _loadMoreCommunities,
                swiperController: _swiperController,
                isFetchingInitialData: _isFetchingInitialData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Community> _getFilteredCommunities() {
    return _selectedCategory == 'Tutto'
        ? _communities
        : _communities
            .where(
                (community) => community.categories.contains(_selectedCategory))
            .toList();
  }

  Future<void> _refreshData() async {
    _fetchInitialData();
  }

  
}
