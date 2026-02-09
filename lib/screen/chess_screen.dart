import 'package:chess_app/screen/settings_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/chess_board.dart';
import '../constants/colors.dart';

class ChessScreen extends StatelessWidget {
  const ChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 20,right: 20), child: const Text("Forked Mind", style: TextStyle(fontSize: 10, color: Colors.white,fontWeight: FontWeight.w400,),),)  ,
                      GestureDetector(
                        onTap: () {
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const ChessBoard(),
          ],
        ),
      ),
    );
  }
}
