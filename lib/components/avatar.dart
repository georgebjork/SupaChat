
import 'package:chat_app/models/profile.dart';
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

  Widget? getAvatar(){
    
    // If profile is null, load a loading circle avatar
    if(profile == null){
      return CircleAvatar(
        radius: radius,
        child: preloader,
      );
    }

    // If the url is null, then return an avatar with text
    if(profile!.avatarURL == null){
      return CircleAvatar(
        radius: radius,
        child: Text(profile!.username.substring(0, 2).toUpperCase(), style: TextStyle(fontSize: fontSize)),
      );
    }

    // If we have all of the data, return the avatar with the image
    return CircleAvatar(
      backgroundImage: NetworkImage(profile!.avatarURL ?? ''),
      radius: radius,
    );
  }
  //


  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: getAvatar()
    );
  }
}