import 'package:algolia/algolia.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/communityCard/communityDiscoveryCard.dart';
import 'package:dima/widgets/searchBar/searchBarSearchingWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config.dart';
import '../model/article.dart';
import '../model/community.dart';
import '../model/globals.dart';
import '../utils/login_prompt.dart';
import '../widgets/articleCard/articleDiscoveryCard.dart';
import '../managers/provider/article_provider.dart';

class SearchingPage extends StatefulWidget {
  const SearchingPage({Key? key}) : super(key: key);

  @override
  SearchingPageState createState() => SearchingPageState();
}

class SearchingPageState extends State<SearchingPage> {
  late Algolia algolia;
  List<Article> searchResultsArticle = [];
  List<Community> searchResultsCommunity = [];
  bool isSearching = false;
  String _selectedPanel = "Articoli"; // Track the selected panel
  CommunityController communityController = CommunityController();

  void onSearch(String query, String category) async {
    setState(() {
      isSearching = true; // Show a loading indicator or similar
    });
    // Assuming ArticleProvider().searchFirestore returns a Future<List<Article>>
    if (query != '') {
      if (_selectedPanel == "Articoli") {
        await searchArticles(query, category);
      } else {
        await searchCommunities(query, category);
      }
    }
    setState(() {
      // searchResults = results;
      isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    algolia = const Algolia.init(
        applicationId: AlgoliaApplicationID, apiKey: AlgoliaAPIKey);
  }

  Future<void> searchArticles(String searchQuery, String category) async {
    searchResultsArticle = [];
    String filterString = category != "tutto" ? 'category:$category' : "";
    AlgoliaQuery query =
        algolia.instance.index('article_index').query(searchQuery);
    // Apply the category filter if needed
    if (filterString.isNotEmpty) {
      query = query.filters(filterString);
    }

    final snap = await query.getObjects();
    final results = snap.hits;
    // Extract document IDs (objectIDs) from Algolia results
    List<String> docIds = results.map((result) => result.objectID).toList();

    // Fetch articles in batches to avoid exceeding Firestore limits
    List<Article> fetchedArticles = await ArticleRepository().fetchArticlesInBatch(docIds);

    // Assuming you have a way to handle or display these articles
    searchResultsArticle.addAll(fetchedArticles);
  }

  Future<void> searchCommunities(String searchQuery, String category) async {
    searchResultsCommunity = [];
    String filterString = category != "tutto" ? 'category:"$category"' : "";
    AlgoliaQuery query =
        algolia.instance.index('community_index').query(searchQuery);
    // Apply the category filter if needed
    if (filterString.isNotEmpty) {
      query = query.filters(filterString);
    }

    final snap = await query.getObjects();
    final results = snap.hits;
    // Extract document IDs (objectIDs) from Algolia results
    List<String> docIds = results.map((result) => result.objectID).toList();

    // Fetch articles in batches to avoid exceeding Firestore limits
    List<Community> fetchedArticles =
        await communityController.fetchCommunityDocID(docIds);

    // Assuming you have a way to handle or display these articles
    searchResultsCommunity.addAll(fetchedArticles);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Palette.offWhite,
      appBar: AppBar(
        title: Text('Cerca',
            style: TextStyle(
              color: Palette.red,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Palette.offWhite,
        foregroundColor: Palette.black,
      ),
      resizeToAvoidBottomInset: false, // Add this line
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            Container(
              color: Palette.offWhite, // Background color for search bar
              height: constraints.maxHeight * 0.1,
              child: SearchBarSearching(
                  onSearch: onSearch, selectedPanel: _selectedPanel),
            ),
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
                child: _selectedPanel == "Articoli"
                    ? _buildArticleContent(constraints)
                    : Globals.instance.userUid != null
                        ? _buildCommunityContent(constraints)
                        : loginPrompt())
          ],
        );
      }),
    );
  }

  Widget _buildArticleContent(BoxConstraints constraints) {
    if (isSearching) {
      return Container(
        color: Palette.offWhite,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
          ),
        ),
      );
    } else if (searchResultsArticle.isEmpty) {
      return Container(
        color: Palette.offWhite,
        child: Center(
          child: Text(
            'Nessun articolo trovato',
            style: TextStyle(
              fontSize: 16.sp,
              color: Palette.black.withOpacity(0.8),
            ),
          ),
        ),
      );
    } else {
      return GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          mainAxisSpacing: 5,
        ),
        itemCount: searchResultsArticle.length,
        itemBuilder: (context, index) {
          Article article = searchResultsArticle[index];
          return Container(
            color: Palette.offWhite, // Background color for each article
            child: ArticleCardDiscovery(
              article: article,
              height: constraints.maxHeight * 0.45,
            ),
          );
        },
      );
    }
  }

  Widget _buildCommunityContent(BoxConstraints constraints) {
    if (isSearching) {
      return Container(
        color: Palette.offWhite,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
          ),
        ),
      );
    } else if (searchResultsCommunity.isEmpty) {
      return Container(
          color: Palette.offWhite,
          child: Center(
            child: Text(
              'Nessuna community trovata',
              style: TextStyle(
                fontSize: 16.sp,
                color: Palette.black.withOpacity(0.8),
              ),
            ),
          ));
    } else {
      return GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          mainAxisSpacing: 5,
        ),
        itemCount: searchResultsCommunity.length,
        itemBuilder: (context, index) {
          Community community = searchResultsCommunity[index];
          // Assuming you have a CommunityCard widget similar to ArticleCardDiscovery
          return Container(
            color: Palette.offWhite, // Background color for each community
            child: CommunityDiscoveryCard(
              community: community,
              height: constraints.maxHeight * 0.45,
              admin: null,
            ),
          );
        },
      );
    }
  }
}
