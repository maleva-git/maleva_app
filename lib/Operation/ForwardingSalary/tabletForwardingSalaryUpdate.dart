part of 'package:maleva/Operation/ForwardingSalary/ForwardingSalaryUpdate.dart';



Widget tabletdesign(OldForwardingSalaryUpdateState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.all(16),
    color: Colors.white,
    child: Center(
      child: Text(
        'Forwarding Salary Update',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
