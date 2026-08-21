
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/fuelentry_bloc.dart';
import '../bloc/fuelentry_event.dart';
import '../bloc/fuelentry_state.dart';
import 'fuelentry_add_edit.dart';
import '../../../../../core/colors/colors.dart';

class FuelEntryTab extends StatefulWidget {
  const FuelEntryTab({Key? key}) : super(key: key);

  @override
  State<FuelEntryTab> createState() => _FuelEntryTabState();
}

class _FuelEntryTabState extends State<FuelEntryTab> {
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final format = DateFormat('yyyy-MM-dd');
    context.read<FuelEntryBloc>().add(LoadFuelEntries(format.format(firstDay), format.format(lastDay)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<FuelEntryBloc, FuelEntryState>(
        listener: (context, state) {
          if (state is FuelEntryActionSuccess) {
            toastMsg(state.message, '', context);
          } else if (state is FuelEntryError) {
            toastMsg(state.message, '', context);
          }
        },
        builder: (context, state) {
          if (state is FuelEntryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FuelEntryLoaded) {
            final allEntries = state.entries;
            final entries = allEntries.where((e) => 
                e.entryNo.toLowerCase().contains(searchQuery.toLowerCase()) ||
                e.truckName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                e.driverName.toLowerCase().contains(searchQuery.toLowerCase())
            ).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: entries.isEmpty 
                    ? const Center(child: Text("No Fuel Entries Found"))
                    : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(AppColors.appBarColor),
                          columns: const [
                            DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('Entry No', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('Date', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('Truck Name', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('Driver Name', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('P. Liter', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('P. Rate', style: TextStyle(color: Colors.white))),
                            DataColumn(label: Text('P. Amount', style: TextStyle(color: Colors.white))),
                          ],
                          rows: entries.map((e) {
                            return DataRow(cells: [
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      final bloc = context.read<FuelEntryBloc>();
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: bloc, child: FuelEntryAddEdit(entry: e))));
                                    },
                                  ),
                                  IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        bool confirm = await ConfirmationMsgYesNo(context, "Are you sure you want to delete this Fuel Entry?");
                                        if (confirm && context.mounted) {
                                          context.read<FuelEntryBloc>().add(DeleteFuelEntry(e.id));
                                        }
                                      },
                                    ),
                                ],
                              )),
                              DataCell(Text(e.entryNo)),
                              DataCell(Text(e.entryDate)),
                              DataCell(Text(e.truckName)),
                              DataCell(Text(e.driverName)),
                              DataCell(Text(e.pLiter.toString())),
                              DataCell(Text(e.pRate.toString())),
                              DataCell(Text(e.pAmount.toString())),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.appBarColor,
        onPressed: () {
          final bloc = context.read<FuelEntryBloc>();
          Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: bloc, child: const FuelEntryAddEdit())));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
