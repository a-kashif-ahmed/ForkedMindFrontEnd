import 'package:flutter/material.dart';

class DropdownSettingsTile extends StatefulWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const DropdownSettingsTile({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<DropdownSettingsTile> createState() => _DropdownSettingsTileState();
}

class _DropdownSettingsTileState extends State<DropdownSettingsTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title,style: TextStyle(color: Colors.white),),
            subtitle: Text(widget.selected, style: TextStyle(color: Colors.white54),),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more, color: Colors.white,
            ),
            onTap: () {
              setState(() => expanded = !expanded);
            },
          ),
      
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 20.0),
              child: Column(
                children: widget.options.map((option) {
                  return ListTile(
                    title: Text(option,style: TextStyle(color: Colors.white54)),
                    trailing: option == widget.selected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      widget.onChanged(option);
                      setState(() => expanded = false);
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
