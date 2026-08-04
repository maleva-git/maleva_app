import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/widgets/maleva_inputs.dart';
import 'package:maleva/features/mastersearch/Customer.dart';
import '../bloc/sale_update_bloc.dart';
import '../bloc/sale_update_event.dart';
import '../bloc/sale_update_state.dart';
import '../models/sale_order_update_model.dart';
import 'sale_update_edit_page.dart';

class SaleUpdateTab extends StatefulWidget {
  const SaleUpdateTab({Key? key}) : super(key: key);

  @override
  State<SaleUpdateTab> createState() => _SaleUpdateTabState();
}

class _SaleUpdateTabState extends State<SaleUpdateTab> {
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  final TextEditingController _txtCustomer = TextEditingController();
  int customerId = 0;
  String _remarksFilter = 'all';

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void _search() {
    context.read<SaleUpdateBloc>().add(
      SearchSaleOrdersEvent(
        fromDate: fromDate,
        toDate: toDate,
        customerId: customerId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;




    return Column(
      children: [
        _buildFilters(context, isTablet),
        Expanded(
          child: BlocBuilder<SaleUpdateBloc, SaleUpdateState>(
            builder: (context, state) {
              if (state is SaleUpdateLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SaleUpdateError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is SaleUpdateLoaded) {
                return _buildList(state.saleOrders, isTablet);
              }
              return const Center(child: Text('Please select criteria and search.'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16.0 : 8.0),
      color: colour.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MalevaDateField(
                  date: DateFormat('dd-MM-yyyy').format(fromDate),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MalevaDateField(
                  date: DateFormat('dd-MM-yyyy').format(toDate),
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: MalevaSearchField(
                  hint: 'Select Customer',
                  uniqueId: 'customerSearch',
                  value: _txtCustomer.text,
                  enabled: true,
                  onSearch: () async {
                    final result = await Navigator.push(
                      context,

                      MaterialPageRoute(builder: (context) => const Customer(Searchby: 1, SearchId: 0)),
                    );
                    if (result != null) {
                      try {
                        setState(() {
                          _txtCustomer.text = result.AccountName;
                          customerId = result.Id;
                        });
                      } catch (e) {
                         setState(() {
                           _txtCustomer.text = result['AccountName'] ?? result['CustomerName'] ?? '';
                           customerId = result['Id'] ?? result['CustomerId'] ?? 0;
                         });
                      }
                    }
                  },
                  onClear: () {
                    setState(() {
                      _txtCustomer.clear();
                      customerId = 0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    label: Text('Search', style: AppTypography.bodyMedium(color: Colors.white, fontWeight: FontWeight.bold)),
                    icon: const Icon(Icons.search, color: Colors.white, size: 20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.brand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _search,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Reference:', style: AppTypography.bodyMedium(color: colour.textMain, fontWeight: FontWeight.bold)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'all',
                        groupValue: _remarksFilter,
                        activeColor: colour.brand,
                        onChanged: (val) => setState(() => _remarksFilter = val!),
                      ),
                      Text('All', style: AppTypography.bodyMedium(color: colour.textMain)),
                      Radio<String>(
                        value: 'with',
                        groupValue: _remarksFilter,
                        activeColor: colour.brand,
                        onChanged: (val) => setState(() => _remarksFilter = val!),
                      ),
                      Text('With', style: AppTypography.bodyMedium(color: colour.textMain)),
                      Radio<String>(
                        value: 'without',
                        groupValue: _remarksFilter,
                        activeColor: colour.brand,
                        onChanged: (val) => setState(() => _remarksFilter = val!),
                      ),
                      Text('Without', style: AppTypography.bodyMedium(color: colour.textMain)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<SaleOrderUpdateModel> allItems, bool isTablet) {
    final items = allItems.where((item) {
      if (_remarksFilter == 'with') return item.remarks1.trim().isNotEmpty;
      if (_remarksFilter == 'without') return item.remarks1.trim().isEmpty;
      return true;
    }).toList();
    if (items.isEmpty) {
      return Center(child: Text('No records found.', style: AppTypography.bodyLarge(color: colour.textSub)));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: colour.border),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 8,
            vertical: 6,
          ),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => BlocProvider.value(
                    value: context.read<SaleUpdateBloc>(),
                    child: SaleUpdateEditPage(model: item),
                  ),
                ),
              ).then((_) => _search()); // Refresh on return
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.cNumberDisplay, style: AppTypography.heading3(color: colour.textMain)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colour.brandLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(item.saleDate, style: AppTypography.badgeText(color: colour.brandDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: colour.textSub),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item.customerName, style: AppTypography.bodyMedium(color: colour.textMain)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.note_alt_outlined, size: 16, color: colour.textSub),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item.remarks1.isEmpty ? 'No Reference' : item.remarks1,
                            style: AppTypography.bodyMedium(color: colour.textSub)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colour.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flight_takeoff, size: 14, color: colour.brand),
                        const SizedBox(width: 6),
                        Expanded(child: Text(item.origin, style: AppTypography.bodySmall(color: colour.textMain))),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: colour.textSub),
                        const SizedBox(width: 6),
                        Expanded(child: Text(item.destination, style: AppTypography.bodySmall(color: colour.textMain))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
