import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/widgets/maleva_inputs.dart';
import '../bloc/sale_update_bloc.dart';
import '../bloc/sale_update_event.dart';
import '../bloc/sale_update_state.dart';
import '../models/sale_order_update_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SaleUpdateEditPage extends StatefulWidget {
  final SaleOrderUpdateModel model;

  const SaleUpdateEditPage({Key? key, required this.model}) : super(key: key);

  @override
  State<SaleUpdateEditPage> createState() => _SaleUpdateEditPageState();
}

class _SaleUpdateEditPageState extends State<SaleUpdateEditPage> {
  late TextEditingController _txtCNumber;
  late TextEditingController _txtSaleDate;
  late TextEditingController _txtRemarks1;
  late TextEditingController _txtOrigin;
  late TextEditingController _txtDestination;

  @override
  void initState() {
    super.initState();
    _txtCNumber = TextEditingController(text: widget.model.cNumberDisplay);
    _txtSaleDate = TextEditingController(text: widget.model.saleDate);
    _txtRemarks1 = TextEditingController(text: widget.model.remarks1);
    _txtOrigin = TextEditingController(text: widget.model.origin);
    _txtDestination = TextEditingController(text: widget.model.destination);
  }

  @override
  void dispose() {
    _txtCNumber.dispose();
    _txtSaleDate.dispose();
    _txtRemarks1.dispose();
    _txtOrigin.dispose();
    _txtDestination.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<SaleUpdateBloc>().add(
      SubmitSaleOrderUpdateEvent(
        id: widget.model.id,
        remarks1: _txtRemarks1.text.trim(),
        origin: _txtOrigin.text.trim(),
        destination: _txtDestination.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: colour.surface,
      appBar: CustomGradientAppBar(
        title: 'Edit Sale Order',
        isTablet: isTablet,
        showBackButton: true,
      ),
      body: BlocConsumer<SaleUpdateBloc, SaleUpdateState>(
        listener: (context, state) {
          if (state is SaleUpdateSubmitSuccess) {
            Fluttertoast.showToast(msg: "Updated successfully", backgroundColor: colour.green);
            Navigator.pop(context);
          } else if (state is SaleUpdateError) {
            Fluttertoast.showToast(msg: "Error: ${state.message}", backgroundColor: colour.red);
          }
        },
        builder: (context, state) {
          bool isLoading = state is SaleUpdateSubmitting;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Order Details', style: AppTypography.heading2(color: colour.textMain)),
                  const SizedBox(height: 16),
                  MalevaTextField(
                    hint: 'CNumber Display',
                    uniqueId: 'cnumber',
                    value: widget.model.cNumberDisplay,
                    enabled: false,
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 16),
                  MalevaTextField(
                    hint: 'Sale Date',
                    uniqueId: 'saledate',
                    value: widget.model.saleDate,
                    enabled: false,
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: 24),
                  Text('Update Fields', style: AppTypography.heading2(color: colour.textMain)),
                  const SizedBox(height: 16),
                  MalevaTextField(
                    hint: 'Reference Number (Remarks)',
                    uniqueId: 'remarks1',
                    value: _txtRemarks1.text,
                    enabled: true,
                    onChanged: (v) => _txtRemarks1.text = v,
                  ),
                  const SizedBox(height: 16),
                  MalevaTextField(
                    hint: 'Origin',
                    uniqueId: 'origin',
                    value: _txtOrigin.text,
                    enabled: true,
                    onChanged: (v) => _txtOrigin.text = v,
                  ),
                  const SizedBox(height: 16),
                  MalevaTextField(
                    hint: 'Destination',
                    uniqueId: 'destination',
                    value: _txtDestination.text,
                    enabled: true,
                    onChanged: (v) => _txtDestination.text = v,
                  ),
                  const SizedBox(height: 32),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colour.brand,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _submit,
                            child: Text('Update Sale Order', style: AppTypography.bodyMedium(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
