import 'package:chess_app/widgets/dropdown_tile.dart';
import 'package:chess_app/widgets/edit_tile.dart';
import 'package:flutter/material.dart';
import '../widgets/settings_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool playAsWhite = true;
  bool allowIllegalMoves = false;
  String apiKeys = '';
  bool allowAIMoveSuggestion = false;
  String boardTheme = '';
  String piecesTheme = '';
  String language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      
      appBar: AppBar(title: Text("Settings"),backgroundColor: Colors.black45,foregroundColor: Colors.white,),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              EditableSettingsTile(title: "API Keys", value: apiKeys, onSaved: (v){
                  setState(() {
                    apiKeys = v;
                  });
                }),
              SettingsSwitchTile(
                title: "Play As White Always",
                value: playAsWhite,
                onChanged: (v) {
                  setState(() => playAsWhite = v);
                },
              ),
              SettingsSwitchTile(title: "Allow Illegal Moves", value: allowIllegalMoves, onChanged: (v) {
                  setState(() => allowIllegalMoves = v);
                },),
                SettingsSwitchTile(title: "Allow AI Suggestions", value: allowAIMoveSuggestion, onChanged: (v){
                  setState(() {
                    allowAIMoveSuggestion = v;
                  });
                  
                }),
                DropdownSettingsTile(title: "Board Theme", options: [
                  "Black & White",
                  "Red & Green"
                ], selected:boardTheme , onChanged: (v){
                  setState(() {
                    boardTheme = v;
                  });
                }),
                DropdownSettingsTile(title: " Pieces Theme", options: [
                  "Black & White",
                  "Red & Green"
                ], selected:piecesTheme , onChanged: (v){
                  setState(() {
                    piecesTheme = v;
                  });
                }),
                DropdownSettingsTile(title: "Language", options: [
                  'English','Spanish','French'
                ], selected:language , onChanged: (v){
                  setState(() {
                    language = v;
                  });
                })
        
            ],
          ),
        ),
      ),
    );
  }
}
