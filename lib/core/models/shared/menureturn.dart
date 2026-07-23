import 'package:maleva/core/models/shared/menu_master_model.dart';

class Menureturn {
  final List<MenuMasterModel> master;
  final List<MenuMasterModel> parent;
  Menureturn(this.master, this.parent);
}