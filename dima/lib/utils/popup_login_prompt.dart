import 'package:dima/managers/provider/navigation_provider.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget popupLoginPrompt() {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final double squareSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth * 0.7
            : constraints.maxHeight * 0.7;

        return Container(
          width: squareSize,
          height: squareSize,
          padding: EdgeInsets.symmetric(horizontal: squareSize * 0.1),
          decoration: BoxDecoration(
            color: Palette.offWhite,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Effettua il login per accedere alle community",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: squareSize * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: squareSize * 0.1),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Palette.red),
                  foregroundColor: MaterialStateProperty.all(Palette.offWhite),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(
                      horizontal: squareSize * 0.2,
                      vertical: squareSize * 0.05,
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Accedi',
                  style: TextStyle(
                    fontSize: squareSize * 0.08,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
