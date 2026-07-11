abstract class BocEvent {}

class LoadBocReport extends BocEvent {
  final String searchValue;
  LoadBocReport({this.searchValue = ''});
}