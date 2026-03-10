import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../../emailinbox/bloc/emailinbox_event.dart';
import '../bloc/googlereview_bloc.dart';
import '../bloc/googlereview_event.dart';
import '../bloc/googlereview_state.dart';
import 'googlereview_grid.dart';


// ── Color Palette ─────────────────────────────────────────────────────────────
const Color kPrimary      = Color(0xFF1555F3);
const Color kPrimaryDark  = Color(0xFF0D3DB5);
const Color kPrimaryLight = Color(0xFF4D7EF7);
const Color kAccent       = Color(0xFFE8EEFF);
const Color kWhite        = Colors.white;

// ── Entry Point ───────────────────────────────────────────────────────────────
class ReviewEntryPage extends StatelessWidget {
  final Review? existingReview;
  const ReviewEntryPage({super.key, this.existingReview});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReviewBloc(context)..add(const LoadEmployeeEvent()),
      child: ReviewEntryForm(existingReview: existingReview),
    );
  }
}

// ── Entry Form ────────────────────────────────────────────────────────────────
class ReviewEntryForm extends StatefulWidget {
  final Review? existingReview;
  const ReviewEntryForm({super.key, this.existingReview});

  @override
  State<ReviewEntryForm> createState() => _ReviewEntryFormState();
}

class _ReviewEntryFormState extends State<ReviewEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _shopCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _reviewMsgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.existingReview != null) {
      final r = widget.existingReview!;
      _shopCtrl.text = r.shopName;
      _reviewMsgCtrl.text = r.googleReview ?? '';
    }
  }

  @override
  void dispose() {
    _shopCtrl.dispose();
    _mobileCtrl.dispose();
    _reviewMsgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) async {
        if (state is ReviewSaveSuccess) {
          await objfun.ConfirmationOK(state.message, context);
          // Reset form
          _shopCtrl.clear();
          _mobileCtrl.clear();
          _reviewMsgCtrl.clear();
          context.read<ReviewBloc>().add(const ResetFormEvent());
        }
        if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is ReviewEmployeesLoading) {
          return const Center(
              child: CircularProgressIndicator(color: kPrimary));
        }

        if (state is! ReviewFormState) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Shop Name ──
                  _buildField(
                    controller: _shopCtrl,
                    label: 'Company Name',
                    validator: (v) =>
                    v!.isEmpty ? 'Enter Company Name' : null,
                  ),
                  const SizedBox(height: 12),

                  // ── Mobile (conditional) ──
                  if (state.showMobileField) ...[
                    _buildField(
                      controller: _mobileCtrl,
                      label: 'Mobile No',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ── Google Review Dropdown ──
                  _buildDropdownContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: state.selectedReview,
                        isExpanded: true,
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: kPrimary),
                        items: List.generate(5, (i) => i + 1)
                            .map((val) => DropdownMenuItem(
                          value: val,
                          child: Text(
                            '⭐' * val + '  ($val)',
                            style: GoogleFonts.lato(
                                color: kPrimaryDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context
                                .read<ReviewBloc>()
                                .add(SelectReviewEvent(val));
                          }
                        },
                      ),
                    ),
                    label: 'Google Review',
                  ),
                  const SizedBox(height: 12),

                  // ── Review Message ──
                  _buildField(
                    controller: _reviewMsgCtrl,
                    label: 'Google Review Message',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // ── Employee Dropdown ──
                  _buildDropdownContainer(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: state.employees.any(
                                (e) => e.Id == state.selectedEmpId)
                            ? state.selectedEmpId
                            : null,
                        isExpanded: true,
                        hint: Text('Select Employee',
                            style: GoogleFonts.lato(color: Colors.grey)),
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: kPrimary),
                        items: state.employees
                            .map((e) => DropdownMenuItem(
                          value: e.Id,
                          child: Text(
                            e.AccountName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                                color: kPrimaryDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            context
                                .read<ReviewBloc>()
                                .add(SelectEmployeesEvent(v));
                          }
                        },
                      ),
                    ),
                    label: 'Employee',
                  ),
                  const SizedBox(height: 12),

                  // ── Date Picker ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: kPrimaryLight.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: kPrimary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(state.selectedDate)}',
                            style: GoogleFonts.lato(
                                color: kPrimaryDark,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_calendar_rounded,
                              color: kPrimary),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: state.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              context
                                  .read<ReviewBloc>()
                                  .add(SelectDateEvent(picked));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: state.saving
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: kWhite, strokeWidth: 2),
                          )
                              : const Icon(Icons.save_rounded,
                              color: kWhite),
                          label: Text(
                            state.saving ? "Saving..." : "Save",
                            style: GoogleFonts.lato(
                                color: kWhite,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: state.saving
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<ReviewBloc>().add(
                                SaveReviewEvent(
                                  shopName: _shopCtrl.text.trim(),
                                  mobileNo:
                                  _mobileCtrl.text.trim(),
                                  reviewMsg:
                                  _reviewMsgCtrl.text.trim(),
                                  existingId:
                                  widget.existingReview?.id,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.grid_view_rounded,
                              color: kPrimary),
                          label: Text("View",
                              style: GoogleFonts.lato(
                                  color: kPrimary,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReviewGridPage()),
                            );
                            if (result == true) {
                              context
                                  .read<ReviewBloc>()
                                  .add(const LoadEmployeeEvent());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.lato(color: kPrimaryDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: Colors.grey[600]),
        filled: true,
        fillColor: kAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownContainer(
      {required Widget child, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(12),
            border:
            Border.all(color: kPrimaryLight.withOpacity(0.3)),
          ),
          child: child,
        ),
      ],
    );
  }
}