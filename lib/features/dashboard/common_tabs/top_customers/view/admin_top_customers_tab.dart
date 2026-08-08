import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/colors/colors.dart';
import '../bloc/top_customers_bloc.dart';
import '../models/top_customer.dart';
import 'package:intl/intl.dart';

class AdminTopCustomersTab extends StatefulWidget {
  final int comid;
  final String fromDate;
  final String toDate;

  const AdminTopCustomersTab({
    Key? key,
    required this.comid,
    required this.fromDate,
    required this.toDate,
  }) : super(key: key);

  @override
  State<AdminTopCustomersTab> createState() => _AdminTopCustomersTabState();
}

class _AdminTopCustomersTabState extends State<AdminTopCustomersTab> {
  String selectedFilter = 'SGD';
  final List<String> filters = ['SGD', 'RM', 'USD', 'TRANSPORT', 'VOLUME'];
  late String currentFromDate;
  late String currentToDate;
  bool isDateFilterEnabled = false;

  @override
  void initState() {
    super.initState();
    currentFromDate = widget.fromDate;
    currentToDate = widget.toDate;
    _fetchData();
  }

  @override
  void didUpdateWidget(AdminTopCustomersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comid != widget.comid) {
      _fetchData();
    }
  }

  void _fetchData() {
    // If date filter is disabled, maybe we should pass empty strings or a very wide date range.
    // Assuming the API requires fromdate and todate, we'll pass 2000-01-01 to 2100-01-01 if disabled.
    final fDate = isDateFilterEnabled ? currentFromDate : '2000-01-01';
    final tDate = isDateFilterEnabled ? currentToDate : '2100-01-01';

    context.read<TopCustomersBloc>().add(
      FetchTopCustomers(widget.comid, fDate, tDate, selectedFilter),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final initialDate = isFromDate
        ? DateTime.parse(currentFromDate)
        : DateTime.parse(currentToDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: const Color(0xFF0D47A1),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        if (isFromDate) {
          currentFromDate = formattedDate;
        } else {
          currentToDate = formattedDate;
        }
      });
    }
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(symbol: '', decimalDigits: 2);
    return format.format(amount).trim();
  }

  Widget _buildDateFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: isDateFilterEnabled,
                activeColor: const Color(0xFF0D47A1),
                onChanged: (val) {
                  setState(() {
                    isDateFilterEnabled = val ?? false;
                  });
                },
              ),
              const Text(
                'Filter by Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (isDateFilterEnabled)
                ElevatedButton.icon(
                  onPressed: _fetchData,
                  icon: const Icon(Icons.search, size: 18, color: Colors.white),
                  label: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
          if (isDateFilterEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currentFromDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const Icon(Icons.calendar_today, size: 16, color: Color(0xFF0D47A1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('TO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF0D47A1).withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currentToDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const Icon(Icons.event, size: 16, color: Color(0xFF0D47A1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF0D47A1),
                  onChanged: (val) {
                    if (val == true) {
                      setState(() {
                        selectedFilter = filter;
                      });
                      _fetchData();
                    }
                  },
                ),
                Text(
                  filter == 'TRANSPORT' ? 'Transport' : filter == 'VOLUME' ? 'Volume & Revenue' : filter,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF0D47A1) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateFilterRow(),
        _buildFilterChips(),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: BlocBuilder<TopCustomersBloc, TopCustomersState>(
            builder: (context, state) {
              if (state is TopCustomersLoading || state is TopCustomersInitial) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
              } else if (state is TopCustomersError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (state is TopCustomersLoaded) {
                if (state.customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'No Customers Found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.customers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final customer = state.customers[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0D47A1).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0D47A1).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.cases_rounded, size: 14, color: Color(0xFF0D47A1)),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Total Jobs: ${customer.volume}',
                                                style: const TextStyle(
                                                  color: Color(0xFF0D47A1),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            
                                            
                                            Expanded(
                                              child: Text(
                                                _formatCurrency(customer.revenue),
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
