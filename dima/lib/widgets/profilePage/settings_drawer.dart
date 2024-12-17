import 'package:dima/pages/auth_page.dart';
import 'package:dima/utils/palette.dart';
import 'package:dima/widgets/profilePage/categorySelectionProfile.dart';
import 'package:dima/widgets/profilePage/change_password.dart';
import 'package:dima/widgets/profilePage/sourcesSelectionProfile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsDrawer extends StatefulWidget {
  final String userId;
  final double width;
  const SettingsDrawer({required this.userId, Key? key, required this.width})
      : super(key: key);

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  int _selectedIndex = 0;

  // Lista delle opzioni del Drawer
  final List<String> drawerOptions = [
    "Seleziona Categorie",
    "Seleziona Fonti",
    "Modifica Password",
    "Chi Siamo"
  ];

  final List<IconData> iconOptions = [
    Icons.category,
    Icons.source,
    Icons.password,
    Icons.person
  ];

  void signUserOut(BuildContext context) async {
    await firebase.FirebaseAuth.instance.signOut();
    // Navigate to AuthPage after sign out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Drawer(
      width: widget.width * 0.70,
      backgroundColor: Palette.offWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.sp, 70.sp, 16.sp, 0),
            child: Text(
              'Impostazioni',
              style: TextStyle(
                fontSize: 24.sp,
                color: Palette.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_selectedIndex == 0)
            Expanded(
              child: ListView.builder(
                itemCount: drawerOptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: 18.sp),
                        children: <InlineSpan>[
                          WidgetSpan(
                            child: Icon(iconOptions[index],
                                size: 22.sp, color: Palette.red),
                          ),
                          TextSpan(
                            text: '  ${drawerOptions[index]}',
                            style: TextStyle(color: Palette.black),
                          ),
                        ],
                      ),
                      softWrap: true, // Abilita il wrapping del testo
                      overflow: TextOverflow
                          .visible, // Evita che il testo venga tagliato
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index + 1;
                      });
                    },
                  );
                },
              ),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                        ),
                        Text(
                          drawerOptions[_selectedIndex - 1],
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildPageContent(_selectedIndex - 1),
                  ),
                ],
              ),
            ),
          Divider(color: Palette.black),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(16.sp)),
                  onPressed: () {
                    Navigator.pop(context);
                    signUserOut(context);
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Palette.offWhite),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return CategorySelectionProfile(userID: widget.userId);
      case 1:
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SourceSelectionProfile(userID: widget.userId),
            ),
          ],
        );
      case 2:
        return ChangePassword();
      case 3:
        return Padding(
          padding: EdgeInsets.all(16.sp),
          child: Text(
            'NewsTalk è la tua app per notizie personalizzate e interazione sociale. '
            'Offriamo articoli aggiornati dalle fonti più affidabili, permettendoti di '
            'scegliere le notizie che più ti interessano. '
            '\nCon NewsTalk, puoi anche unirti a comunità tematiche per discutere e condividere '
            'opinioni su argomenti di tuo interesse.',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Palette.black,
              height: 1.5.sp,
            ),
            textAlign: TextAlign.justify,
          ),
        );
      default:
        return const Text("Errore");
    }
  }
}
