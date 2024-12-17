import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/model/community.dart';
import 'package:dima/utils/login_prompt.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import '../managers/provider/article_provider.dart';
import '../model/article.dart';
import '../model/globals.dart';
import '../utils/placeholder_flipCard.dart';
import 'articleCard/articleDiscoveryCard.dart';
import 'communityCard/communityDiscoveryCard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedDiscoveryWidget extends StatefulWidget {
  const FeedDiscoveryWidget({super.key});

  @override
  _FeedDiscoveryWidgetState createState() => _FeedDiscoveryWidgetState();
}

class _FeedDiscoveryWidgetState extends State<FeedDiscoveryWidget> {
  String _selectedPanel = "Articoli";
  CommunityController communityController = CommunityController();

  @override
  Widget build(BuildContext context) {
     ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            Container(
              color: Palette.offWhite,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPanel = "Articoli";
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        margin: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 5.sp),
                        decoration: _selectedPanel == "Articoli"
                            ? BoxDecoration(
                                color: Palette.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              )
                            : const BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              color: _selectedPanel == "Articoli"
                                  ? Palette.red
                                  : Palette.grey,
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              "Articoli",
                              style: TextStyle(
                                color: _selectedPanel == "Articoli"
                                    ? Palette.red
                                    : Palette.grey,
                                fontSize: 16.sp,
                                fontWeight: _selectedPanel == "Articoli"
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * 0.5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPanel = "Community";
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 20.sp),
                        margin: EdgeInsets.symmetric(
                            vertical: 10.sp, horizontal: 5.sp),
                        decoration: _selectedPanel == "Community"
                            ? BoxDecoration(
                                color: Palette.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              )
                            : const BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.groups,
                              color: _selectedPanel == "Community"
                                  ? Palette.red
                                  : Palette.grey,
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              "Community",
                              style: TextStyle(
                                color: _selectedPanel == "Community"
                                    ? Palette.red
                                    : Palette.grey,
                                fontSize: 16.sp,
                                fontWeight: _selectedPanel == "Community"
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(constraints),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    if (_selectedPanel == "Articoli") {
      return FutureBuilder<List<List<Article>>>(
        future: ArticleRepository().retrieveAllArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Palette.offWhite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  return buildArticlePlaceholder(context);
                },
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun articolo trovato'));
          }
          List<Article> articles = snapshot.data!.expand((x) => x).toList();
          return Container(
            color: Palette.offWhite,
            child: GridView.builder(
              scrollDirection: Axis.horizontal, // Enables horizontal scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Single column for horizontal layout
                childAspectRatio: 1.3, // Adjust aspect ratio if needed
                mainAxisSpacing: 5, // Spacing between items in the main axis
              ),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                Article article = articles[index];
                return ArticleCardDiscovery(
                  article: article,
                  height: constraints.maxHeight * 0.5,
                );
              },
            ),
          );
        },
      );
    } else if (Globals.instance.userUid != null) {
      return FutureBuilder<List<Community>>(
        future: communityController.fetchCommunities(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Community>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Palette.offWhite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  return buildArticlePlaceholder(context);
                },
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessuna community trovata'));
          }

          List<Community> communities = snapshot.data!;

          return Container(
            color: Palette.offWhite,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Adjust as per your needs
                childAspectRatio: 1.3, // Adjust aspect ratio if needed
                mainAxisSpacing: 5, // Spacing between items in the main axis
              ),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                Community community = communities[index];
                return CommunityDiscoveryCard(
                  community: community,
                  height: constraints.maxHeight * 0.5,
                  admin: null, // Adjust as per your needs
                );
              },
            ),
          );
        },
      );
    } else {
      return loginPrompt();
    }
  }
}
