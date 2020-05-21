import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.title,
          ),
          SizedBox(
            height: 3.0,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[200],
            ),
            child: TextField(
              controller: controller,
              obscureText: obsecureText,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide.none),
                suffixIcon: suffixIcon != null
                    ? InkWell(
                        onTap: () {},
                        child: Icon(
                          suffixIcon,
                          color: Colors.grey,
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
}
