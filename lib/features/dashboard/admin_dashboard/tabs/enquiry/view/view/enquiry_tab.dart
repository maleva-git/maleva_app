import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../../Transaction/SaleOrder/SalesOrderAdd.dart';
import '../../../../../../../core/colors/colors.dart' as colour;
import '../../../../../../../core/theme/tokens.dart';
import '../../../../../../../core/utils/clsfunction.dart' as objfun;
import '../../add/view/enquiryadd.dart';
import '../bloc/enquiry_bloc.dart';
import '../bloc/enquiry_event.dart';
import '../bloc/enquiry_state.dart';

class EnquiryScreen extends StatelessWidget {
  const EnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnquiryBloc()..add(LoadEnquiryEvent()),
      child: const _EnquiryView(),
    );
  }
}

class _EnquiryView extends StatelessWidget {
  const _EnquiryView();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return BlocListener<EnquiryBloc, EnquiryState>(
      listenWhen: (prev, curr) => curr.errorMessage != null,
      listener: (context, state) {
        objfun.msgshow(
          state.errorMessage!,
          '',
          Colors.white,
          Colors.red,
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
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.only(
                top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: [

                // ── Add Button ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 5),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.invoiceHeaderStart,
                side: const BorderSide(
                  color: colour.cWhite,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                elevation: 20.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(4.0),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEnquiryScreen()),
                ).then((_) {
                  context.read<EnquiryBloc>().add(LoadEnquiryEvent());
                });
              },
              child: const Icon(
                Icons.add,
                color: Colors.white, // ✅ plus symbol white
              ),
            ),
                  ],
                ),
                const SizedBox(height: 5),

                // ── Grid Header ──
                SizedBox(
                  height: height * 0.05,
                  child: Container(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    color: colour.commonColor,
                    child: _buildGridHeader(),
                  ),
                ),

                // ── List ──
                SizedBox(
                  height: height * 0.80,
                  child: state.enquiryList.isNotEmpty
                      ? ListView.builder(
                    itemCount: state.enquiryList.length,
                    itemBuilder: (context, index) {
                      final item = state.enquiryList[index];
                      return _EnquiryCard(
                        item: item,
                        index: index,
                        height: height,
                      );
                    },
                  )
                      : SizedBox(
                    width: width - 40.0,
                    height: height / 1.4,
                    child: const Center(
                      child: Text('No Record'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridHeader() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Customer Name',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.ButtonForeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLow,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Notify Date',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.ButtonForeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLow,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Enquiry Card ──
class _EnquiryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final double height;

  const _EnquiryCard({
    required this.item,
    required this.index,
    required this.height,
  });

  Color _cardColor(int index) {
    // உங்க existing _CardColor logic இங்க போடு
    return index.isEven
        ? colour.commonColorLight
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.07,
      child: InkWell(
        onDoubleTap: () {
          _showEnqDetails(context, item);
        },
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
        child: Card(
          color: _cardColor(index),
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
                color: colour.commonColor, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              // ── Row 1: Customer + Date ──
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      child: Text(
                        '   ${item["CustomerName"]}',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontCardText,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      child: Text(
                        '   ${item["SForwardingDate"]}',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontCardText,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Row 2: Actions ──
              Row(
                children: [
                  // Push to SalesOrder
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        bool result =
                        await objfun.ConfirmationMsgYesNo(
                          context,
                          'Do You Want to Push to SalesOrder ?',
                        );
                        if (result == true) {
                          objfun.storagenew
                              .setString('EnquiryOpen', 'true');
                          final List<dynamic> enquiryList = [item];
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SalesOrderAdd(
                                SaleDetails: null,
                                SaleMaster: enquiryList,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.fast_forward_sharp,
                        color: colour.commonColor,
                      ),
                    ),
                  ),
                  // Cancel
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        bool result =
                        await objfun.ConfirmationMsgYesNo(
                          context,
                          'Do You Want to Cancel the Enquiry ?',
                        );
                        if (result == true) {
                          context.read<EnquiryBloc>().add(
                            CancelEnquiryEvent(item['Id']),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: colour.commonColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnqDetails(
      BuildContext context, Map<String, dynamic> item) {
    // உங்க existing _showDialogEnqDetails logic இங்க போடு
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item['CustomerName'] ?? ''),
        content: Text(item['SForwardingDate'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}