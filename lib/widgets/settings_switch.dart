import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),

        // Material-only colors (ignored on iOS automatically)
        activeColor: Colors.green,
        inactiveThumbColor: const Color.fromARGB(255, 245, 185, 181),
        inactiveTrackColor: Colors.red,
      ),
    );
  }
}
