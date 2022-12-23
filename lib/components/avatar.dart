
import 'package:chat_app/models/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/utils/constants.dart';

class Avatar extends StatelessWidget {

  const Avatar({
    Key? key,
    required this.profile,
    this.onPressed,
    this.radius,
    this.fontSize
  }) : super(key: key);

  final Profile? profile;
  final VoidCallback? onPressed;
  final double? radius;
  final double? fontSize;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: radius,
        child: profile == null
            ? preloader
            : Text(profile!.username.substring(0, 2).toUpperCase(), style: TextStyle(fontSize: fontSize),),
      ),
    );
  }
}