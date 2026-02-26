import 'package:flutter/material.dart';
import '../../core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

class Addemployee extends StatefulWidget {
  final EmployeeDetailsModel? existingEmployee; // when editing

  const Addemployee({super.key, this.existingEmployee});

  @override
  State<Addemployee> createState() => _EmployeeStepperFormState();
}
class EmployeeType {
  final int id;
  final String name;
  EmployeeType(this.id, this.name);
}

class _EmployeeStepperFormState extends State<Addemployee> {
  int _currentStep = 0;
  bool progress = false;
  // Model instance
  late EmployeeDetailsModel employee = widget.existingEmployee ?? EmployeeDetailsModel.Empty();

  String? selectedRuleType;
//currency
  String? selectedCurrency;
  List<String> countryCurrencyList = ["INR", "RM", "USD", "EUR"]; // add as needed



  List<String> rulesTypeList = [
    "SALES",
    "HR",
    "ADMIN",
    "OPERATION",
    "BOARDING",
    "FORWARDING",
    "AIR FRIEGHT",
    "ACCOUNTS",
    "TRANSPORTATION",
    "MAINTENANCE",
    "OPERATIONADMIN",
    "HRADMIN",
    "SECONDADMIN"
  ];
  final List<EmployeeType> employeeTypeList = [
    EmployeeType(1, "ADMIN"),
    EmployeeType(2, "ACCOUNTS"),
    EmployeeType(3, "HR"),
    EmployeeType(4, "BILLING"),
    EmployeeType(5, "OPERATION"),
    EmployeeType(6, "SALES"),
    EmployeeType(7, "MAINTENANCE"),
    EmployeeType(8, "TRANSPORTATION"),
    EmployeeType(9, "FORWARDING"),
    EmployeeType(10, "RECEIVABLE"),
    EmployeeType(11, "PAYABLE"),
    EmployeeType(12, "BOARDING"),
    EmployeeType(13, "OPERATIONADMIN"),
    EmployeeType(14, "CustomerServiceAdmin"),
    EmployeeType(15, "HRADMIN"),
  ];

  String? selectedEmployeeType;


  // Controllers for all fields
  final _nameCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipcodeCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _joiningCtrl = TextEditingController();
  final _leavingCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController();
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accNoCtrl = TextEditingController();
  final _accCodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 🧠 Initialize model
    employee = widget.existingEmployee ?? EmployeeDetailsModel.Empty();

    // 🧾 Prefill data if editing
    _nameCtrl.text = employee.EmployeeName;
    _currencyCtrl.text = employee.Employeecurrency;
    _typeCtrl.text = employee.EmployeeType;
    _emailCtrl.text = employee.Email;
    _mobileCtrl.text = employee.MobileNo;
    _emergencyCtrl.text = employee.EmergencyNo;
    _address1Ctrl.text = employee.Address1;
    _address2Ctrl.text = employee.Address2;
    _cityCtrl.text = employee.City;
    _stateCtrl.text = employee.State;
    _zipcodeCtrl.text = employee.Zipcode;
    _countryCtrl.text = employee.Country;
    _gstCtrl.text = employee.GSTNO;
    _usernameCtrl.text = employee.UserName;
    _joiningCtrl.text = employee.JoiningDate;
    _leavingCtrl.text = employee.LeavingDate;
    _passwordCtrl.text = employee.Password;
    _rulesCtrl.text = employee.RulesType;
    _latitudeCtrl.text = employee.Latitude;
    _longitudeCtrl.text = employee.longitude;
    _bankCtrl.text = employee.BankName;
    _accNoCtrl.text = employee.AccountNo;
    _accCodeCtrl.text = employee.AccountCode;

    selectedEmployeeType = employeeTypeList
        .any((et) => et.name == employee.EmployeeType)
        ? employee.EmployeeType
        : null;

    selectedCurrency = countryCurrencyList
        .contains(employee.Employeecurrency)
        ? employee.Employeecurrency
        : null;

    selectedRuleType = rulesTypeList
        .contains(employee.RulesType)
        ? employee.RulesType
        : null;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(employee.Id == 0 ? "Add Employee" : "Edit Employee"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () async {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              bool? confirmSave = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: const Text(
                    "Confirm Save",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text("Do you want to save this employee’s details?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Yes, Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (confirmSave == true) _saveEmployee();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
            else Navigator.pop(context);
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(_currentStep == 3 ? "Save" : "Next"),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Back"),
                ),
              ],
            );
          },
          steps: [
            // Step 1: Basic Info
            Step(
              title: const Text("Basic Info", style: TextStyle(fontWeight: FontWeight.bold)),
              content: _buildSection([
                _buildTextField("Employee Name", _nameCtrl),
                _buildDropdown("Select Currency", selectedCurrency, countryCurrencyList, (val) {
                  setState(() => selectedCurrency = val);
                }),
                _buildDropdown("Employee Type", selectedEmployeeType,
                    employeeTypeList.map((e) => e.name).toList(), (val) {
                      setState(() {
                        selectedEmployeeType = val;
                        _typeCtrl.text = val ?? "";
                      });
                    }),
                _buildTextField("Email", _emailCtrl),
                _buildTextField("Mobile No", _mobileCtrl),
                _buildTextField("Emergency No", _emergencyCtrl),
              ]),
            ),

            // Step 2: Address Info
            Step(
              title: const Text("Address Info", style: TextStyle(fontWeight: FontWeight.bold)),
              content: _buildSection([
                _buildTextField("Address 1", _address1Ctrl),
                _buildTextField("Address 2", _address2Ctrl),
                _buildTextField("City", _cityCtrl),
                _buildTextField("State", _stateCtrl),
                _buildTextField("Zipcode", _zipcodeCtrl),
                _buildTextField("Country", _countryCtrl),
                _buildTextField("GST No", _gstCtrl),
              ]),
            ),

            // Step 3: Job Info
            Step(
              title: const Text("Job Info", style: TextStyle(fontWeight: FontWeight.bold)),
              content: _buildSection([
                _buildTextField("User Name", _usernameCtrl),
                _buildDatePicker("Joining Date", _joiningCtrl),
                _buildDatePicker("Leaving Date", _leavingCtrl),

                _buildTextField("Password", _passwordCtrl),
                _buildDropdown("Rules Type", selectedRuleType, rulesTypeList, (val) {
                  setState(() => selectedRuleType = val);
                }),
                _buildTextField("Latitude", _latitudeCtrl),
                _buildTextField("Longitude", _longitudeCtrl),
              ]),
            ),

            // Step 4: Bank Info
            Step(
              title: const Text("Bank Details", style: TextStyle(fontWeight: FontWeight.bold)),
              content: _buildSection([
                _buildTextField("Bank Name", _bankCtrl),
                _buildTextField("Account No", _accNoCtrl),
                _buildTextField("Account Code", _accCodeCtrl),
              ]),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDropdown(
      String label,
      String? value,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.indigo),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: ctrl.text.isNotEmpty
                ? DateTime.tryParse(ctrl.text) ?? DateTime.now()
                : DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() {
              ctrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
  Future _saveEmployee() async {
    // 🧠 Update model from controllers



    employee
      ..EmployeeName = _nameCtrl.text
      ..Employeecurrency = selectedCurrency ?? ""
      ..EmployeeType = selectedEmployeeType ?? ""
      ..Email = _emailCtrl.text
      ..MobileNo = _mobileCtrl.text
      ..EmergencyNo = _emergencyCtrl.text
      ..Address1 = _address1Ctrl.text
      ..Address2 = _address2Ctrl.text
      ..City = _cityCtrl.text
      ..State = _stateCtrl.text
      ..Zipcode = _zipcodeCtrl.text
      ..Country = _countryCtrl.text
      ..GSTNO = _gstCtrl.text
      ..UserName = _usernameCtrl.text
      ..JoiningDate = _joiningCtrl.text
      ..LeavingDate = _leavingCtrl.text
      ..Password = _passwordCtrl.text
      ..RulesType = selectedRuleType ?? ""
      ..Latitude = _latitudeCtrl.text
      ..longitude = _longitudeCtrl.text
      ..BankName = _bankCtrl.text
      ..AccountNo = _accNoCtrl.text
      ..AccountCode = _accCodeCtrl.text;



    // ✅ Now send full model to API
    final master = [employee.toJson()];

    int comid = objfun.storagenew.getInt('Comid') ?? 0;
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Comid': comid.toString(), // convert int to string
    };

    // You can call your single API:
    // await ApiService.saveEmployee(jsonData);
    await objfun
        .apiAllinoneSelectArray(
      objfun.apiInsertEmployeeDetails,
      master,
      header,
      context,
    )
        .then((resultData) async {
      if (resultData != null && resultData.toString().isNotEmpty) {
        // Case 1: resultData is a JSON object
        if (resultData is Map) {
          bool isSuccess = resultData['ok'] ?? false;
          String message = resultData['message'] ?? 'Something went wrong';

          await objfun.ConfirmationOK(message, context);
        }
        // Case 2: resultData is just a number (ID)
        else {
          int id = int.tryParse(resultData.toString()) ?? 0;

          if (id > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Employee updated successfully ✅",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.all(12),
                duration: const Duration(seconds: 2),
              ),
            );


            _clearFields();
          } else {
            await objfun.ConfirmationOK('Unexpected response', context);
          }
        }

        setState(() {
          progress = true;
        });
      }

    }).onError((error, stackTrace) {
      setState(() {
        progress = true;
      });
      objfun.msgshow(
        error.toString(),
        stackTrace.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );
    });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //         employee.Id == 0 ? "Employee Added ✅" : "Employee Updated ✅"),
    //   ),
    // );

   // Navigator.pop(context);
  }

  void _clearFields() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _mobileCtrl.clear();
    _emergencyCtrl.clear();
    _address1Ctrl.clear();
    _address2Ctrl.clear();
    _cityCtrl.clear();
    _stateCtrl.clear();
    _zipcodeCtrl.clear();
    _countryCtrl.clear();
    _gstCtrl.clear();
    _usernameCtrl.clear();
    _joiningCtrl.clear();
    _leavingCtrl.clear();
    _passwordCtrl.clear();
    _latitudeCtrl.clear();
    _longitudeCtrl.clear();
    _bankCtrl.clear();
    _accNoCtrl.clear();
    _accCodeCtrl.clear();

    // 🔹 Reset dropdown selections
    setState(() {
      selectedCurrency = null;
      selectedEmployeeType = null;
      selectedRuleType = null;
      _currentStep = 0; // go back to first step
    });
  }

}
