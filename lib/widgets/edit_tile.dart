import 'package:flutter/material.dart';

class EditableSettingsTile extends StatefulWidget {
  final String title;
  final String value;
  final ValueChanged<String> onSaved;

  const EditableSettingsTile({
    super.key,
    required this.title,
    required this.value,
    required this.onSaved,
  });

  @override
  State<EditableSettingsTile> createState() => _EditableSettingsTileState();
}

class _EditableSettingsTileState extends State<EditableSettingsTile> {
  bool isEditing = false;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
      child: ListTile(
        title: Text(widget.title,style: TextStyle(color: Colors.white),),
      
        subtitle: isEditing
            ? TextField(
                controller: controller,
                autofocus: true,
                onSubmitted: _save,
                style: TextStyle(color:Colors.white),
                autocorrect: false,
                decoration: InputDecoration(enabledBorder: UnderlineInputBorder(      
                      borderSide: BorderSide(color: Colors.cyan),   
                      ),  
              focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 21, 212, 0)),
                   ),  
             ),
              )
            : Text(widget.value, style: TextStyle(color: Colors.white60),),
      
        trailing: IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit,color: Colors.white,),
          onPressed: () {
            if (isEditing) {
              _save(controller.text);
            } else {
              setState(() => isEditing = true);
            }
          },
        ),
      ),
    );
  }

  void _save(String value) {
    widget.onSaved(value);
    setState(() => isEditing = false);
  }
}
