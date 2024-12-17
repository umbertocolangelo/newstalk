import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget loginPrompt({double? height, double? width}) {
  return Scaffold(
    backgroundColor: Palette.offWhite,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double containerWidth = width ?? constraints.maxWidth * 0.8;
          final double containerHeight = height ?? constraints.maxHeight * 0.4;

          return Center(
            child: Container(
              width: containerWidth,
              height: containerHeight,
              padding: EdgeInsets.all(containerWidth * 0.05),
              decoration: BoxDecoration(
                color: Palette.offWhite,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Effettua il login per accedere alle community",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: containerWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: containerHeight * 0.1),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Palette.red),
                      foregroundColor:
                          MaterialStateProperty.all(Palette.offWhite),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          horizontal: containerWidth * 0.1,
                          vertical: containerHeight * 0.05, 
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(10),
                    ),
                    onPressed: () {
                      Provider.of<NavigationProvider>(context, listen: false)
                          .setIndex(4);
                    },
                    child: Text(
                      'Accedi',
                      style: TextStyle(
                        fontSize: containerWidth * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
