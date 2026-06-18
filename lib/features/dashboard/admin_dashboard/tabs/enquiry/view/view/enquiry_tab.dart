import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../core/theme/palette.dart';

import '../../../../../../../core/di/injection.dart';
import '../../../../../../../core/utils/clsfunction.dart' as objfun;
import '../../../../../../transaction/salesorder/add/view/salesorderadd_tab.dart';
import '../../../saleorderadd/view/saleorderadd_tab.dart';
import '../../add/view/enquiryadd.dart';
import '../bloc/enquiry_bloc.dart';
import '../bloc/enquiry_event.dart';
import '../bloc/enquiry_state.dart';
import '../data/enquiry_repository.dart';

class EnquiryScreen extends StatelessWidget {
  const EnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnquiryBloc(
        repository: sl<EnquiryRepository>(),
      )..add(LoadEnquiryEvent()), // Good practice to load on init
      child: const _EnquiryView(),
    );
  }
}

class _EnquiryView extends StatelessWidget {
  const _EnquiryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.grey50, // Clean background
      body: BlocListener<EnquiryBloc, EnquiryState>(
        listenWhen: (prev, curr) => curr.errorMessage != null,
        listener: (context, state) {
          objfun.msgshow(
            state.errorMessage!,
            '',
            Palette.white,
            Palette.redError,
            null,
            18.00 - objfun.reducesize,
            objfun.tll,
            objfun.tgc,
            context,
            2,
          );
        },
        child: BlocBuilder<EnquiryBloc, EnquiryState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Palette.blue600),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // ── Action Bar (Add Button) ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.blue600,
                          foregroundColor: Palette.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddEnquiryScreen()),
                          ).then((_) {
                            context.read<EnquiryBloc>().add(LoadEnquiryEvent());
                          });
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'New Enquiry',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Grid Header ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Palette.blue50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Palette.blue200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Customer Name',
                            style: GoogleFonts.lato(
                              color: Palette.blue900,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Notify Date',
                            style: GoogleFonts.lato(
                              color: Palette.blue900,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Empty spacer to align with the action buttons on the cards
                        const SizedBox(width: 80),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── List ──
                  Expanded(
                    child: state.enquiryList.isNotEmpty
                        ? ListView.builder(
                      itemCount: state.enquiryList.length,
                      itemBuilder: (context, index) {
                        final item = state.enquiryList[index];
                        return _EnquiryCard(
                          item: item,
                          index: index,
                        );
                      },
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 64, color: Palette.grey400),
                          const SizedBox(height: 16),
                          Text(
                            'No Records Found',
                            style: GoogleFonts.lato(
                              color: Palette.textMuted,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Enquiry Card ──
class _EnquiryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _EnquiryCard({
    required this.item,
    required this.index,
  });

  Color _cardColor(int index) {
    return index.isEven ? Palette.white : Palette.grey50;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onDoubleTap: () => _showEnqDetails(context, item),
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEnquiryScreen(saleMaster: item),
            ),
          ).then((_) {
            context.read<EnquiryBloc>().add(LoadEnquiryEvent());
          });
        },
        child: Ink(
          decoration: BoxDecoration(
            color: _cardColor(index),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Palette.grey200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000), // Subtle shadow
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Customer Name ──
                Expanded(
                  flex: 2,
                  child: Text(
                    item["CustomerName"] ?? 'Unknown',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.lato(
                      color: Palette.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),

                // ── Date ──
                Expanded(
                  flex: 2,
                  child: Text(
                    item["SForwardingDate"] ?? '-',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.lato(
                      color: Palette.textMuted,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                // ── Actions ──
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Push to SalesOrder
                      _ActionButton(
                        icon: Icons.fast_forward_rounded,
                        color: Palette.blueMid,
                        bgColor: Palette.chipBg,
                        onTap: () async {
                          bool result = await objfun.ConfirmationMsgYesNo(
                            context,
                            'Do You Want to Push to SalesOrder?',
                          );
                          if (result == true) {
                            objfun.storagenew.setString('EnquiryOpen', 'true');
                            final List<dynamic> enquiryList = [item];
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SalesOrdersAdd(
                                    SaleDetails: null,
                                    SaleMaster: enquiryList,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      // Cancel
                      _ActionButton(
                        icon: Icons.close_rounded,
                        color: Palette.rose,
                        bgColor: Palette.rose.withOpacity(0.1),
                        onTap: () async {
                          bool result = await objfun.ConfirmationMsgYesNo(
                            context,
                            'Do You Want to Cancel the Enquiry?',
                          );
                          if (result == true && context.mounted) {
                            context
                                .read<EnquiryBloc>()
                                .add(CancelEnquiryEvent(item['Id']));
                          }
                        },
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
  }

  void _showEnqDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Palette.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          item['CustomerName'] ?? '',
          style: GoogleFonts.lato(color: Palette.textDark2),
        ),
        content: Text(
          'Date: ${item['SForwardingDate'] ?? ''}',
          style: GoogleFonts.lato(color: Palette.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Palette.blue600),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom widget for modern looking icon buttons
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }
}