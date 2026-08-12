import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/rti_activities/rti_activities_bloc.dart';
import '../bloc/rti_activities/rti_activities_event.dart';
import '../bloc/rti_activities/rti_activities_state.dart';
import '../../../../core/colors/colors.dart';

class RtiRouteActivitiesTab extends StatefulWidget {
  const RtiRouteActivitiesTab({super.key});

  @override
  State<RtiRouteActivitiesTab> createState() => _RtiRouteActivitiesTabState();
}

class _RtiRouteActivitiesTabState extends State<RtiRouteActivitiesTab> {
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    context.read<RtiActivitiesBloc>().add(FetchRtiActivities(_fromDate, _toDate));
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? _fromDate : _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.appBarColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getBgColor(String jobType) {
    switch (jobType) {
      case 'SEAL': return const Color(0xFFF4F7FF); // light blue
      case 'BREAK_SEAL': return const Color(0xFFFFF4F4); // light red
      case 'SEAL_AND_BREAK': return const Color(0xFFF9F4FF); // light purple
      case 'K1 Clearance': return const Color(0xFFF4FFF6); // light green
      case 'K2 Clearance': return const Color(0xFFFFFBF4); // light orange
      case 'K3 Clearance': return const Color(0xFFFFF4FC); // light pink
      case 'K8 Clearance': return const Color(0xFFF4FFFF); // light cyan
      default: return const Color(0xFFF5F5F5); // light grey
    }
  }

  Color _getBorderColor(String jobType) {
    switch (jobType) {
      case 'SEAL': return const Color(0xFF4A72FF);
      case 'BREAK_SEAL': return const Color(0xFFFF4A4A);
      case 'SEAL_AND_BREAK': return const Color(0xFFA64AFF);
      case 'K1 Clearance': return const Color(0xFF4AFF79);
      case 'K2 Clearance': return const Color(0xFFFFB34A);
      case 'K3 Clearance': return const Color(0xFFFF4AEB);
      case 'K8 Clearance': return const Color(0xFF4AEBFF);
      default: return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Filters
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.appBarColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_fromDate),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.appBarColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_toDate),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _fetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appBarColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        
        // List View
        Expanded(
          child: BlocConsumer<RtiActivitiesBloc, RtiActivitiesState>(
            listener: (context, state) {
              if (state is RtiActivitiesActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.actionMessage, style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is RtiActivitiesLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.appBarColor));
              } else if (state is RtiActivitiesError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is RtiActivitiesLoaded) {
                if (state.activities.isEmpty) {
                  return const Center(child: Text("No Data Found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: state.activities.length,
                  itemBuilder: (context, index) {
                    final activity = state.activities[index];
                    
                    final bgColor = _getBgColor(activity.activityType);
                    final borderColor = _getBorderColor(activity.activityType);
                    
                    String formattedEta = 'N/A';
                    if (activity.eta != null && activity.eta!.isNotEmpty) {
                      try {
                        final DateTime dt = DateTime.parse(activity.eta!);
                        formattedEta = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
                      } catch (_) {
                        formattedEta = activity.eta!;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 6,
                              child: Container(color: borderColor),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0).copyWith(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: RTI No (Lorry No) & Status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Lorry No: ${activity.rtiNumber.isNotEmpty ? activity.rtiNumber : 'N/A'}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            color: borderColor.withValues(alpha: 0.9),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<int>(
                                        initialValue: activity.status,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        onSelected: (int newValue) {
                                          if (newValue != activity.status) {
                                            context.read<RtiActivitiesBloc>().add(
                                              UpdateRtiStatus(activity.id, newValue)
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 0,
                                            child: Text('PENDING', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                          ),
                                          const PopupMenuItem(
                                            value: 1,
                                            child: Text('COMPLETED', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                          ),
                                        ],
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: activity.status == 1 ? Colors.green.shade100 : Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: activity.status == 1 ? Colors.green.shade300 : Colors.orange.shade300, 
                                              width: 1
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                activity.status == 1 ? 'COMPLETED' : 'PENDING',
                                                style: TextStyle(
                                                  color: activity.status == 1 ? Colors.green.shade800 : Colors.orange.shade900,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.keyboard_arrow_down_rounded, 
                                                size: 16, 
                                                color: activity.status == 1 ? Colors.green.shade800 : Colors.orange.shade900
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Destination, Job Type & ETA
                                  _buildInfoRow(Icons.location_on_rounded, "Destination", activity.locationName.isNotEmpty ? activity.locationName : 'N/A', borderColor),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(Icons.work_rounded, "Job Type", activity.activityType.isNotEmpty ? activity.activityType : 'N/A', borderColor),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(Icons.map_rounded, "Full Route", activity.fullRoute.isNotEmpty ? activity.fullRoute : 'N/A', borderColor),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(Icons.access_time_filled_rounded, "ETA", formattedEta, borderColor),
                                  
                                  
                                  if (activity.marqisStatus == 1)
                                    Container(
                                      margin: const EdgeInsets.only(top: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Marqis: this truck is need the Marqis",
                                              style: TextStyle(
                                                color: Colors.red.shade800,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                  const SizedBox(height: 16),
                                  
                                  // Driver Info Container
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildInfoRow(Icons.badge_rounded, "Driver Name", activity.employeeName.isNotEmpty ? activity.employeeName : 'N/A', Colors.black87),
                                        const SizedBox(height: 10),
                                        _buildInfoRow(Icons.phone_android_rounded, "Driver Number", activity.driverNumber.isNotEmpty ? activity.driverNumber : 'N/A', Colors.black87),
                                      ],
                                    ),
                                  ),
                                  
                                  // Remarks
                                  if (activity.remarks.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 16),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: borderColor.withValues(alpha: 0.2), width: 1),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.notes_rounded, size: 16, color: borderColor),
                                              const SizedBox(width: 6),
                                              Text(
                                                "Remarks",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: borderColor),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            activity.remarks,
                                            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
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
