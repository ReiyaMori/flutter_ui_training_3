
import 'package:flutter/cupertino.dart';

class MainModel extends ChangeNotifier{
  int currentIndex = 0;
  String currentPageTitle = 'Battery Optimizer';

  void tabTap(int index, String text){
    currentIndex = index;
    currentPageTitle = text;
    notifyListeners();
  }
}