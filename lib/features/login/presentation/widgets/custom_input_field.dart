import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final double padding;
  final String label;
  final bool obsecureText;
  final IconData suffixIcon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const CustomInputField({
    this.padding = 20.0,
    @required this.label,
    this.obsecureText = false,
    this.suffixIcon,
    @required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _showPassword;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.title,
          ),
          SizedBox(
            height: 3.0,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).cardColor,
            ),
            child: TextField(
              controller: widget.controller,
              obscureText:
                  _showPassword == null ? widget.obsecureText : _showPassword,
              keyboardType: widget.keyboardType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                suffixIcon: widget.suffixIcon != null
                    ? InkWell(
                        onTap: togglePasswordSecureState,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            widget.suffixIcon,
                            color: _showPassword != null
                                ? !_showPassword
                                    ? Colors.deepOrange
                                    : Colors.grey
                                : Colors.grey,
                          ),
                        ),
                      )
                    : Container(width: 0.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void togglePasswordSecureState() {
    setState(() {
      if (_showPassword == null) _showPassword = true;
      _showPassword = !_showPassword;
    });
  }
}
