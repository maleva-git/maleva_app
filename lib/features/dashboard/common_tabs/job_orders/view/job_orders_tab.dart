import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/job_orders_bloc.dart';
import '../bloc/job_orders_event.dart';
import '../bloc/job_orders_state.dart';
import '../models/job_order.dart';
import '../models/job_order_detail.dart';
import '../models/job_order_type.dart';
import '../../../../../core/colors/colors.dart';

class JobOrdersTab extends StatefulWidget {
  const JobOrdersTab({super.key});

  @override
  State<JobOrdersTab> createState() => _JobOrdersTabState();
}

class _JobOrdersTabState extends State<JobOrdersTab> {
  @override
  void initState() {
    super.initState();
    _fetchJobOrders();
  }

  void _fetchJobOrders() {
    context.read<JobOrdersBloc>().add(const FetchJobOrders());
  }

  Color _getStatusColor(int statusRefId) {
    switch (statusRefId) {
      case 1: // Open
        return const Color(0xFF3B82F6); // Soft Blue
      case 2: // In Progress
        return const Color(0xFFF59E0B); // Amber/Orange
      case 3: // Completed
        return const Color(0xFF10B981); // Emerald Green
      case 4: // Cancelled
        return const Color(0xFF6B7280); // Cool Grey (Instead of Red)
      default:
        return Colors.grey;
    }
  }

  void _showJobDetails(BuildContext context, JobOrder job, List<JobOrderDetail> allDetails) {
    final details = allDetails.where((d) => d.jobOrderMasterRefId == job.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          height: MediaQuery.of(context).size.height * 0.75, // 75% height
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Job Details: ${job.cNumberDisplay}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              
              if (details.isEmpty)
                const Expanded(child: Center(child: Text("No detailed records found for this job order.", style: TextStyle(color: Colors.grey))))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final detail = details[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.problemName.isNotEmpty ? detail.problemName.toUpperCase() : 'NO PROBLEM SPECIFIED',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.red.shade700, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 12),
                            
                            _buildInfoRow(Icons.inventory_2_rounded, "Product", detail.productName.isNotEmpty ? detail.productName : '-', Colors.blue.shade600),
                            const SizedBox(height: 8),
                            
                            _buildInfoRow(Icons.category_rounded, "Product Use", detail.productUse.isNotEmpty ? detail.productUse : '-', Colors.orange.shade600),
                            const SizedBox(height: 8),
                            
                            _buildInfoRow(Icons.attach_money_rounded, "Cost", "\$${detail.cost.toStringAsFixed(2)}", Colors.green.shade600),
                            const SizedBox(height: 8),
                            
                            _buildInfoRow(Icons.comment_rounded, "Remarks", detail.remarks.isNotEmpty ? detail.remarks : '-', Colors.grey.shade600),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showStatusUpdateDialog(BuildContext context, JobOrder job, List<JobOrderType> jobTypes) {
    int selectedStatusId = job.statusRefId;
    final jobOrdersBloc = context.read<JobOrdersBloc>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Update Status: ${job.cNumberDisplay}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: jobTypes.length,
                  itemBuilder: (context, index) {
                    final type = jobTypes[index];
                    final isSelected = type.id == selectedStatusId;
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      title: Text(type.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                      onTap: () {
                        setState(() {
                          selectedStatusId = type.id;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStatusId != job.statusRefId) {
                      jobOrdersBloc.add(UpdateJobOrderStatus(job.id, selectedStatusId));
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Update", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTruckSearchBottomSheet(BuildContext context, JobOrdersLoaded state) {
    String searchQuery = '';
    final jobOrdersBloc = context.read<JobOrdersBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredTrucks = state.trucks.where((truck) => truck.AccountName.toLowerCase().contains(searchQuery.toLowerCase())).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Select Truck", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search truck...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredTrucks.length + (searchQuery.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (searchQuery.isEmpty && index == 0) {
                            return ListTile(
                              leading: const Icon(Icons.directions_car, color: Colors.grey),
                              title: const Text("All Trucks", style: TextStyle(fontWeight: FontWeight.bold)),
                              trailing: state.selectedTId == 0 ? const Icon(Icons.check, color: AppColors.appBarColor) : null,
                              onTap: () {
                                jobOrdersBloc.add(FetchJobOrders(jId: state.selectedJId, tId: 0));
                                Navigator.pop(context);
                              },
                            );
                          }
                          
                          final truckIndex = searchQuery.isEmpty ? index - 1 : index;
                          final truck = filteredTrucks[truckIndex];
                          final isSelected = state.selectedTId == truck.Id;
                          
                          return ListTile(
                            leading: const Icon(Icons.local_shipping, color: Colors.grey),
                            title: Text(truck.AccountName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            trailing: isSelected ? const Icon(Icons.check, color: AppColors.appBarColor) : null,
                            onTap: () {
                              jobOrdersBloc.add(FetchJobOrders(jId: state.selectedJId, tId: truck.Id));
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
          // List View
          Expanded(
            child: BlocBuilder<JobOrdersBloc, JobOrdersState>(
              builder: (context, state) {
                if (state is JobOrdersLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.appBarColor));
                } else if (state is JobOrdersError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is JobOrdersLoaded) {
                  return Column(
                    children: [
                      if (state.jobTypes.isNotEmpty)
                        Container(
                          height: 50,
                          margin: const EdgeInsets.only(top: 8, bottom: 4),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.jobTypes.length,
                            itemBuilder: (context, index) {
                              final typeId = state.jobTypes[index].id;
                              final typeName = state.jobTypes[index].name;
                              final isSelected = state.selectedJId == typeId;
                              
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(typeName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected && state.selectedJId != typeId) {
                                      context.read<JobOrdersBloc>().add(FetchJobOrders(jId: typeId, tId: state.selectedTId));
                                    }
                                  },
                                  selectedColor: AppColors.appBarColor,
                                  backgroundColor: Colors.grey.shade100,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected ? AppColors.appBarColor : Colors.grey.shade300,
                                    )
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      if (state.trucks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: InkWell(
                            onTap: () => _showTruckSearchBottomSheet(context, state),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_shipping, color: AppColors.appBarColor, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        state.selectedTId == 0 
                                          ? "All Trucks" 
                                          : state.trucks.firstWhere((t) => t.Id == state.selectedTId, orElse: () => state.trucks.first).AccountName,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: state.jobOrders.isEmpty
                            ? const Center(child: Text("No Job Orders Found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                itemCount: state.jobOrders.length,
                                itemBuilder: (context, index) {
                                  final job = state.jobOrders[index];
                                  final statusColor = _getStatusColor(job.statusRefId);
            
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: InkWell(
                                      onTap: () => _showJobDetails(context, job, state.jobDetails),
                                      onLongPress: () => _showStatusUpdateDialog(context, job, state.jobTypes),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey.shade200, width: 1.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
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
                                            child: Container(color: statusColor),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16.0).copyWith(left: 20),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Header: Truck No & Status
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        job.truckName.isNotEmpty ? job.truckName.toUpperCase() : 'NO TRUCK',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: 20,
                                                          color: Colors.black87,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: statusColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(color: statusColor.withOpacity(0.5)),
                                                      ),
                                                      child: Text(
                                                        job.statusName.toUpperCase(),
                                                        style: TextStyle(
                                                          color: statusColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 11,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "Job No: ${job.cNumberDisplay.isNotEmpty ? job.cNumberDisplay : 'N/A'}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                
                                                // Info Rows
                                                Row(
                                                  children: [
                                                    Expanded(child: _buildInfoRow(Icons.calendar_today_rounded, "Date", job.sJobDate.isNotEmpty ? job.sJobDate : 'N/A', Colors.grey.shade700)),
                                                    const SizedBox(width: 8),
                                                    Expanded(child: _buildInfoRow(Icons.flag_rounded, "Target", job.targetDate.isNotEmpty ? job.targetDate : 'N/A', Colors.orange.shade700)),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                _buildInfoRow(Icons.build_circle_rounded, "Job Type", job.jobTypeName.isNotEmpty ? job.jobTypeName : 'N/A', Colors.grey.shade700),
                                                const SizedBox(height: 10),
                                                _buildInfoRow(Icons.person_rounded, "Driver", job.driverName.isNotEmpty ? job.driverName : 'N/A', Colors.grey.shade700),
                                                
                                                if (job.remarks.isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  _buildInfoRow(Icons.comment_rounded, "Remarks", job.remarks, Colors.grey.shade700),
                                                ],
                                                const SizedBox(height: 12),
                                                const Divider(),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton.icon(
                                                      onPressed: () => _showAttachmentsSheet(context, job),
                                                      icon: const Icon(Icons.attach_file_rounded, size: 18),
                                                      label: const Text("Attachments"),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: AppColors.appBarColor,
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
                              );
                            },
                              ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      );
  }

  // --- ATTACHMENTS LOGIC ---
  Future<void> _showAttachmentsSheet(BuildContext context, JobOrder job) async {
    List<String> images = [];
    List<XFile> pendingUploads = [];
    bool isLoading = true;

    Future<void> loadImages(StateSetter setModalState) async {
      try {
        final String companyId = AppPreferences.getComid().toString();
        
        final response = await http.post(
          Uri.parse(ApiConstants.port + '/Common/FetchFile2'),
          headers: {
            'Comid': companyId,
            'Id': job.id.toString(),
            'FolderName': 'jobs order',
            'FileName': '',
            'SubFolderName': '',
            'DeleteFileName': '',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['ok'] == true && data['Data'] != null) {
            setModalState(() {
              images = List<String>.from(data['Data']);
              isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint('Error loading images: $e');
      }
      setModalState(() {
        isLoading = false;
      });
    }

    Future<void> deleteImage(StateSetter setModalState, String imageUrl) async {
      setModalState(() {
        isLoading = true;
      });

      try {
        final String companyId = AppPreferences.getComid().toString();
        
        final response = await http.post(
          Uri.parse(ApiConstants.port + '/Common/DeleteFile'),
          headers: {
            'Comid': companyId,
            'Id': job.id.toString(),
            'FolderName': 'jobs order',
            'FileName': imageUrl,
            'SubFolderName': '',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['ok'] == true) {
            await loadImages(setModalState);
            return;
          }
        }
      } catch (e) {
        debugPrint('Error deleting image: $e');
      }

      setModalState(() {
        isLoading = false;
      });
    }

    Future<void> pickImages(StateSetter setModalState) async {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setModalState(() {
          pendingUploads.addAll(pickedFiles);
        });
      }
    }

    Future<void> uploadImagesToServer(StateSetter setModalState) async {
      if (pendingUploads.isEmpty) return;

      setModalState(() {
        isLoading = true;
      });

      try {
        final String companyId = AppPreferences.getComid().toString();
        
        var request = http.MultipartRequest(
          'POST', 
          Uri.parse(ApiConstants.port + '/Common/UploadFile5')
        );
        request.headers.addAll({
          'Comid': companyId,
          'Id': job.id.toString(),
          'FolderName': 'jobs order',
          'FileName': '',
          'SubFolderName': '',
          'DeleteFileName': '',
          'ExistingFilePath': '',
        });

        for (int i = 0; i < pendingUploads.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('MyImages$i', pendingUploads[i].path));
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          final resStr = await response.stream.bytesToString();
          final data = json.decode(resStr);
          if (data['ok'] == true) {
            setModalState(() {
              pendingUploads.clear();
            });
            await loadImages(setModalState);
            return;
          }
        }
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }

      setModalState(() {
        isLoading = false;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Load initially
            if (isLoading && images.isEmpty && pendingUploads.isEmpty) {
              loadImages(setModalState);
            }

            final totalItems = images.length + pendingUploads.length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Attachments",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : totalItems == 0
                        ? const Center(child: Text("No attachments found.", style: TextStyle(color: Colors.grey)))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: totalItems,
                            itemBuilder: (context, index) {
                              if (index < images.length) {
                                // Server Image
                                final imgPath = images[index];
                                final imgUrl = ApiConstants.port + imgPath;
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Photo'),
                                              content: const Text('Are you sure you want to delete this photo?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true), 
                                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            deleteImage(setModalState, imgPath);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // Pending Local Image
                                final localImg = pendingUploads[index - images.length];
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(
                                              File(localImg.path),
                                              fit: BoxFit.cover,
                                            ),
                                            Container(color: Colors.black.withValues(alpha: 0.3)),
                                            const Center(
                                              child: Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 30),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            pendingUploads.removeAt(index - images.length);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  if (pendingUploads.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => uploadImagesToServer(setModalState),
                          icon: const Icon(Icons.cloud_upload, color: Colors.white),
                          label: Text("Upload \ Photos", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => pickImages(setModalState),
                      icon: Icon(Icons.add_photo_alternate, color: AppColors.appBarColor),
                      label: Text("Select Photos", style: TextStyle(color: AppColors.appBarColor, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.appBarColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



