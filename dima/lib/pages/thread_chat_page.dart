import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/managers/controllers/article_controller.dart';
import 'package:dima/managers/controllers/comment_controller.dart';
import 'package:dima/managers/controllers/community_controller.dart';
import 'package:dima/managers/controllers/thread_controller.dart';
import 'package:dima/managers/controllers/user_controller.dart';
import 'package:dima/managers/provider/article_provider.dart';
import 'package:dima/model/article.dart';
import 'package:dima/model/comment.dart';
import 'package:dima/model/community.dart';
import 'package:dima/model/globals.dart';
import 'package:dima/model/thread.dart';
import 'package:dima/model/user.dart';
import 'package:dima/pages/community_homepage.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/articleCard/articleDiscoveryCard.dart';
import 'package:dima/widgets/thread/thread_comments.dart';
import 'package:dima/widgets/thread/thread_modify_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/thread/thread_scroll_article_cards.dart';

class ThreadChatPage extends StatefulWidget {
  final String threadId;
  final String currentUserId;

  const ThreadChatPage({
    Key? key,
    required this.threadId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ThreadChatPageState createState() => _ThreadChatPageState();
}

class _ThreadChatPageState extends State<ThreadChatPage> {
  List<User> users = [];
  Map<String, Color> commentColors = {};
  final TextEditingController commentTextController = TextEditingController();
  final CommentController _commentController = CommentController();
  final UserController _userController = UserController();
  final ScrollController _scrollController = ScrollController();
  final ThreadController _threadController = ThreadController();
  bool _showFloatingHeader = false;
  String _lastCommentId = '0';
  List<Article> threadArticles = [];
  ValueNotifier<Article?> articleNotifier =
      ValueNotifier(null); // Image URL notifier
  late Thread thread;
  bool _isThreadLoaded = false;
  bool _isUsersLoaded = false;
  bool get _isLoaded => _isThreadLoaded && _isUsersLoaded;
  String linkedArticleId = "";

  @override
  void initState() {
    super.initState();
    _fetchUsersByThread();
    _fetchThread();
    _scrollController.addListener(_scrollListener);
    commentTextController.addListener(() {
      RegExp exp = RegExp(r'%%(\d{2})%%');
      final text = commentTextController.text;
      final RegExpMatch? match = exp.firstMatch(text);

      if (match != null) {
        String digits = match.group(
            1)!; // Extracts the digits captured by the regular expression
        retrieveImage(digits.toString());
        // Call your method with the extracted digits
        commentTextController
            .clear(); // Optionally clear the input after processing
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArticles();
  }

  // Asynchronous method to load articles
  void _loadArticles() async {
    ArticleController articleController = ArticleController();
    List<Article> articles =
        await articleController.getArticlesByThreadId(widget.threadId);
    setState(() {
      threadArticles = articles;
    });
  }

  void retrieveImage(String articleId) async {
    List<Article> articles = await ArticleRepository().retrieveArticlesForArticleId(articleId);
    if (articles.isNotEmpty) {
      articleNotifier.value = articles.first; // Set the first Article
      updateTextFieldWithArticleTitle(
          articles.first.title); // Update the TextField after successful fetch
    }
  }

  void updateTextFieldWithArticleTitle(String title) {
    // Extract the first 20 characters of the title or the full title if it's shorter
    String newTextFieldContent =
        title.length > 20 ? title.substring(0, 20) + "..." : title + "...";
    final text = commentTextController.text;
    String newText = text.replaceAll('34', newTextFieldContent);
    commentTextController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void _scrollListener() {
    setState(() {
      _showFloatingHeader = _scrollController.offset > 150;
    });
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) <= 50; // 50 pixel from bottom
  }

  void _scrollDown() {
    if (_isNearBottom()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 50), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        });
      });
    }
  }

  String generateRandomId({int length = 8}) {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String randomId = '';

    for (int i = 0; i < length; i++) {
      randomId += characters[random.nextInt(characters.length)];
    }
    return randomId;
  }

  Future<void> _fetchUsersByThread() async {
    final usersData = await _userController.getUsersByThreadId(widget.threadId);
    setState(() {
      users = usersData;
    });
    // Check if participant
    if (!users.any((user) => user.id == widget.currentUserId)) {
      await _threadController
          .addParticipantToThread(widget.threadId, widget.currentUserId)
          .then((_) => _fetchUsersByThread());
    } else {
      setState(() {
        _isUsersLoaded = true;
      });
    }
  }

  Future<void> _fetchThread() async {
    final getThread = await _threadController.getThreadById(widget.threadId);
    setState(() {
      thread = getThread;
      _isThreadLoaded = true;
    });
  }

  Future<void> _addComment(String text) async {
    if (linkedArticleId.isNotEmpty) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        await _threadController.addArticleToThread(
            widget.threadId, linkedArticleId);
        linkedArticleId = "";
      }).then((_) {
        _loadArticles();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Errore durante l\'aggiunta dell articolo: $error')),
        );
      });
    }
    if (text.isNotEmpty) {
      final newComment = Comment(
        id: generateRandomId(),
        threadId: widget.threadId,
        userId: widget.currentUserId,
        content: text,
        time: Timestamp.now(),
      );

      await _commentController.addComment(newComment.toJson());
      await _threadController.addCommentToThread(
          widget.threadId, newComment.id);
      setState(() {
        commentTextController.clear();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 50), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        });
      });
    }
  }

  void _deleteThread(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sei sicuro di voler procedere?"),
          content: Text("Questa azione eliminerà definitivamente il Thread"),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteConfirmed();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Palette.red),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text("Elimina Thread"),
                  ),
                  SizedBox(width: 10.sp),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.black)),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Text("Annulla"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConfirmed() async {
    setState(() {
      _isThreadLoaded = false;
    });

    ThreadController threadController = ThreadController();
    CommunityController communityController = CommunityController();
    UserController userController = UserController();
    CommentController commentController = CommentController();

    Community community =
        await communityController.getCommunityById(thread.communityId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Remove comments
      for (String commentId in thread.commentIds) {
        await commentController.deleteComment(commentId);
      }
      // Delete thread
      await threadController.deleteThread(thread.id);
      // Remove thread from community
      await communityController.removeThreadFromCommunity(
          thread.communityId, thread.id);
      // Remove thread from user
      await userController.removeThreadFromUser(
          Globals.instance.userUid.toString(), thread.id);
    }).then((_) {
      Navigator.pop(context); // close community home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityHomePage(community: community),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thread eliminato con successo')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'eliminazione del Thread: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    if (!_isLoaded) {
      return Scaffold(
          body: Container(
        color: Palette.offWhite,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
          ),
        ),
      ));
    }

    return Scaffold(
        backgroundColor: Palette.offWhite,
        resizeToAvoidBottomInset:
            true, // Ensures the scaffold resizes when the keyboard appears
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Palette.offWhite,
          foregroundColor: Palette.black,
          title: Text(
            'Thread',
            style: TextStyle(
              fontSize: 24.sp,
              color: Palette.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
                color: Palette.offWhite,
                child: Column(
                  children: [
                    if (_showFloatingHeader)
                      ElevatedButton.icon(
                        onPressed: () {
                          _scrollController.animateTo(
                            0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: Icon(Icons.arrow_upward_outlined),
                        label: Text('Torna all\'inizio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.grey.withOpacity(0.5),
                          foregroundColor: Palette.offWhite,
                        ),
                      ),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('threads')
                            .where('id', isEqualTo: widget.threadId)
                            .snapshots(),
                        builder: (context, threadSnapshot) {
                          if (!threadSnapshot.hasData) {
                            return Container(
                              color: Palette.offWhite,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Palette.grey),
                                ),
                              ),
                            );
                          }
                          if (threadSnapshot.hasError) {
                            return Center(
                                child:
                                    Text('Errore nel caricamento del thread'));
                          }

                          Thread threadData = Thread.fromJson(
                              threadSnapshot.data!.docs.first.data());
                          final participantsIds = threadData.participantIds;

                          return StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('id', whereIn: participantsIds)
                                .snapshots(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return Container(
                                  color: Palette.offWhite,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Palette.grey),
                                    ),
                                  ),
                                );
                              }
                              if (userSnapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Errore nel caricamento degli utenti'));
                              }

                              final usersMap = {
                                for (var doc in userSnapshot.data!.docs)
                                  doc.id: User.fromJson(
                                      doc.data() as Map<String, dynamic>),
                              };

                              return StreamBuilder<
                                  QuerySnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('comments')
                                    .where('threadId',
                                        isEqualTo: widget.threadId)
                                    .orderBy('time')
                                    .snapshots(),
                                builder: (context, commentSnapshot) {
                                  if (!commentSnapshot.hasData) {
                                    return Container(
                                      color: Palette.offWhite,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Palette.grey),
                                        ),
                                      ),
                                    );
                                  }
                                  if (commentSnapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Errore nel caricamento dei commenti'));
                                  }

                                  final comments = commentSnapshot.data!.docs
                                      .map((doc) => Comment.fromJson(
                                          doc.data() as Map<String, dynamic>))
                                      .toList();

                                  if (comments.isNotEmpty) {
                                    if (_lastCommentId != comments.last.id) {
                                      _scrollDown();
                                      _lastCommentId = comments.last.id;
                                    }
                                  }

                                  return ListView(
                                    controller: _scrollController,
                                    children: [
                                      ListTile(
                                        leading: ClipOval(
                                          child: SizedBox(
                                            width: 50.sp,
                                            height: 50.sp,
                                            child: usersMap[thread.authorId]!
                                                    .profileImagePath
                                                    .startsWith('assets')
                                                ? Image.asset(
                                                    usersMap[thread.authorId]!
                                                        .profileImagePath,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    usersMap[thread.authorId]!
                                                        .profileImagePath,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent?
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child; // L'immagine è stata caricata
                                                      }
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  (loadingProgress
                                                                          .expectedTotalBytes ??
                                                                      1)
                                                              : null,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Palette.grey),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object error,
                                                            StackTrace?
                                                                stackTrace) {
                                                      return Icon(Icons.error,
                                                          size: 25.sp);
                                                    },
                                                  ),
                                          ),
                                        ),

                                        title: Text(threadData.title,
                                            style: TextStyle(
                                                fontSize: 20.0.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Palette.black)),
                                        subtitle: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Palette.grey,
                                              fontSize: 14.sp,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Creato il ' +
                                                    (threadData.time
                                                            as Timestamp)
                                                        .toDate()
                                                        .day
                                                        .toString() +
                                                    '/' +
                                                    (threadData.time
                                                            as Timestamp)
                                                        .toDate()
                                                        .month
                                                        .toString() +
                                                    '/' +
                                                    (threadData.time
                                                            as Timestamp)
                                                        .toDate()
                                                        .year
                                                        .toString() +
                                                    ' da ',
                                              ),
                                              TextSpan(
                                                text: users.isNotEmpty
                                                    ? usersMap[threadData
                                                                .authorId]
                                                            ?.username ??
                                                        ""
                                                    : "",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Palette.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 20.sp),

                                        // show settings only to the thread author
                                        trailing: (threadData.authorId ==
                                                Globals.instance.userUid
                                                    .toString())
                                            ? PopupMenuButton<String>(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              16.0)),
                                                ),
                                                onSelected: (String value) {
                                                  switch (value) {
                                                    case 'Modifica Titolo':
                                                      // Modify title
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return ThreadModifyTitle(
                                                              threadId: widget
                                                                  .threadId);
                                                        },
                                                      );
                                                      break;
                                                    case 'Elimina Thread':
                                                      // Delete thread
                                                      _deleteThread(context);
                                                      break;
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return [
                                                    PopupMenuItem<String>(
                                                      value: 'Modifica Titolo',
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8.sp,
                                                                horizontal:
                                                                    16.sp),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Palette.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Modifica Titolo',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      value: 'Elimina Thread',
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8.sp,
                                                                horizontal:
                                                                    16.sp),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Palette.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Elimina Thread',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ];
                                                },
                                              )
                                            : null,
                                      ),

                                      // Container per gli articoli
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 8.sp),
                                        child: Container(
                                          height: constraints.maxHeight * 0.3,
                                          child: ThreadScrollArticleCards(
                                            height: constraints.maxHeight * 0.4,
                                            threadArticles: threadArticles,
                                          ),
                                        ),
                                      ),

                                      Divider(),

                                      // Sezione dei commenti
                                      CommentsList(
                                        comments: comments,
                                        commentColors: commentColors,
                                        currentUserId: widget.currentUserId,
                                        users: usersMap.values.toList(),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Campo di input per i commenti
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context)
                                .viewInsets
                                .bottom // Adds padding dynamically at the bottom equal to the keyboard height
                            ),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ValueListenableBuilder<Article?>(
                                valueListenable: articleNotifier,
                                builder: (context, article, child) {
                                  if (article != null) {
                                    linkedArticleId = article.articleId;
                                  }
                                  return article != null
                                      ? SizedBox(
                                          height: constraints.maxHeight * 0.5,
                                          child: SingleChildScrollView(
                                              child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: SizedBox(
                                                      width:
                                                          constraints.maxWidth *
                                                              0.5,
                                                      child: ArticleCardDiscovery(
                                                          article: article,
                                                          height: constraints
                                                                  .maxHeight *
                                                              0.4),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10.sp,
                                                    left: 10.sp,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 1,
                                                            blurRadius: 3,
                                                            offset:
                                                                Offset(0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: IconButton(
                                                        icon: Icon(
                                                          FontAwesomeIcons
                                                              .times,
                                                          color: Colors.black,
                                                          size: 15.sp,
                                                        ),
                                                        onPressed: () {
                                                          articleNotifier
                                                                  .value =
                                                              null; // Reset the Article
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: 20
                                                      .sp), // Space between article card and text
                                              Padding(
                                                padding: EdgeInsets.all(8.sp),
                                                child: Text(
                                                  article.description,
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 0, 0, 0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )))
                                      : SizedBox(); // Placeholder space for image
                                },
                              ),
                              Divider(),
                              Container(
                                color: Palette.offWhite,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          8.sp, 8.sp, 0, 8.sp),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Focus(
                                              child: TextField(
                                                controller:
                                                    commentTextController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Scrivi un commento...',
                                                  hintStyle: TextStyle(
                                                      color: Palette.grey,
                                                      fontSize: 14.sp),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    borderSide: BorderSide(
                                                      color: Palette.grey,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    borderSide: BorderSide(
                                                      color: Palette.black,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                ),
                                                onSubmitted: (text) {
                                                  _addComment(text);
                                                  articleNotifier.value = null;
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4.sp),
                                          IconButton(
                                            onPressed: () {
                                              _addComment(
                                                  commentTextController.text);
                                              articleNotifier.value = null;
                                            },
                                            icon: Icon(
                                              Icons.send_rounded,
                                              color: Palette.red,
                                              size: 30.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        height: constraints.maxHeight * 0.05),
                                  ],
                                ),
                              ),
                            ])),
                  ],
                ));
          },
        ));
  }
}
