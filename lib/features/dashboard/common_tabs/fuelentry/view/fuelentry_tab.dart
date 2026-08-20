
import 'package:flutter/material.dart';
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is FuelEntryError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is FuelEntryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FuelEntryLoaded) {
            final entries = state.entries;
            if (entries.isEmpty) {
              return const Center(child: Text("No Fuel Entries Found"));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.appBarColor),
                  columns: const [
                    DataColumn(label: Text('Action', style: TextStyle(color: Colors.white))),
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
                              Navigator.push(context, MaterialPageRoute(builder: (_) => FuelEntryAddEdit(entry: e)));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              context.read<FuelEntryBloc>().add(DeleteFuelEntry(e.id));
                            },
                          ),
                        ],
                      )),
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
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.appBarColor,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelEntryAddEdit()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
