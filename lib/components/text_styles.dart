import 'package:flutter/material.dart';


TextStyle mainHeaderTextStyle(BuildContext context){
  return TextStyle(
    fontFamily: "tahoma",
    color: Theme.of(context).colorScheme.onPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold
  );
}

TextStyle taskTitleTextSyle(BuildContext context){
  return TextStyle(
    fontFamily: "tahoma",
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onPrimary
  );
}


TextStyle labletaskTitleTextSyle(BuildContext context){
  return TextStyle(
    fontFamily: "tahoma",
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onPrimary
  );
}

TextStyle btntaskTitleTextSyle(BuildContext context){
  return TextStyle(
    fontFamily: "tahoma",
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onPrimary
  );
}