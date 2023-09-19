import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class PicProvider extends ChangeNotifier{
  File? currentImage;

  changeImage(File image){
    currentImage = image;
    notifyListeners();
  }
  File? get getCurrentImage => currentImage;
 }