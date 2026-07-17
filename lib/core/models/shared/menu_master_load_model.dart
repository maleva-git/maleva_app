import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class MenuMasterLoadModel {
  String FormText;
  int PageAdd;
  int PageEdit;
  int PageDelete;
  int PageView;
  MenuMasterLoadModel(this.FormText, this.PageAdd, this.PageEdit,
      this.PageDelete, this.PageView);
}