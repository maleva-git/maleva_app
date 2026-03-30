import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../bloc/googlereview_bloc.dart';
import '../bloc/googlereview_event.dart';
import '../bloc/googlereview_state.dart';
import 'googlereview_grid.dart';



class ReviewEntryPage extends StatelessWidget {
  final Review? existingReview;
  const ReviewEntryPage({super.key, this.existingReview});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ReviewBloc(context)..add(const LoadEmployeeEvent()),
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
  final _formKey       = GlobalKey<FormState>();
  final _shopCtrl      = TextEditingController();
  final _mobileCtrl    = TextEditingController();
  final _reviewMsgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      final r = widget.existingReview!;
      _shopCtrl.text      = r.shopName;
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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) async {
        if (state is ReviewSaveSuccess) {
          await objfun.ConfirmationOK(state.message, context);
          _shopCtrl.clear();
          _mobileCtrl.clear();
          _reviewMsgCtrl.clear();
          context.read<ReviewBloc>().add(const ResetFormEvent());
        }
        if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:         Text(state.message),
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
          child: isTablet
              ? _buildTabletLayout(context, state)
              : _buildMobileLayout(context, state),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, ReviewFormState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (55%) — Title + Form
          Expanded(
            flex: 55,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(children: [
                      Container(
                        width: 4, height: 30,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('GOOGLE REVIEW',
                          style: GoogleFonts.lato(
                            fontSize:      20,
                            fontWeight:    FontWeight.bold,
                            color:         kPrimaryDark,
                            letterSpacing: 1.2,
                          )),
                    ]),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text('Entry Form',
                          style: GoogleFonts.lato(
                            fontSize:   14,
                            color:      kPrimaryLight,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                    const SizedBox(height: 24),

                    // Form fields
                    _buildField(
                      controller: _shopCtrl,
                      label:      'Company Name',
                      isTablet:   true,
                      validator: (v) =>
                      v!.isEmpty ? 'Enter Company Name' : null,
                    ),
                    const SizedBox(height: 14),

                    if (state.showMobileField) ...[
                      _buildField(
                        controller:   _mobileCtrl,
                        label:        'Mobile No',
                        isTablet:     true,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                    ],

                    _buildDropdownContainer(
                      label:   'Google Review',
                      isTablet: true,
                      child: _reviewDropdown(context, state),
                    ),
                    const SizedBox(height: 14),

                    _buildField(
                      controller: _reviewMsgCtrl,
                      label:      'Google Review Message',
                      isTablet:   true,
                      maxLines:   3,
                    ),
                    const SizedBox(height: 14),

                    _buildDropdownContainer(
                      label:   'Employee',
                      isTablet: true,
                      child: _employeeDropdown(context, state),
                    ),
                    const SizedBox(height: 14),

                    _buildDatePicker(context, state, isTablet: true),
                    const SizedBox(height: 28),

                    _buildActionButtons(context, state, isTablet: true),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // ── RIGHT (45%) — Info / Preview Panel
          Expanded(
            flex: 45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                _InfoPanel(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, ReviewFormState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildField(
              controller: _shopCtrl,
              label:      'Company Name',
              isTablet:   false,
              validator: (v) =>
              v!.isEmpty ? 'Enter Company Name' : null,
            ),
            const SizedBox(height: 12),

            if (state.showMobileField) ...[
              _buildField(
                controller:   _mobileCtrl,
                label:        'Mobile No',
                isTablet:     false,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
            ],

            _buildDropdownContainer(
              label:   'Google Review',
              isTablet: false,
              child: _reviewDropdown(context, state),
            ),
            const SizedBox(height: 12),

            _buildField(
              controller: _reviewMsgCtrl,
              label:      'Google Review Message',
              isTablet:   false,
              maxLines:   3,
            ),
            const SizedBox(height: 12),

            _buildDropdownContainer(
              label:   'Employee',
              isTablet: false,
              child: _employeeDropdown(context, state),
            ),
            const SizedBox(height: 12),

            _buildDatePicker(context, state, isTablet: false),
            const SizedBox(height: 24),

            _buildActionButtons(context, state, isTablet: false),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED BUILDERS
  // ══════════════════════════════════════════════════════

  Widget _reviewDropdown(
      BuildContext context, ReviewFormState state) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value:      state.selectedReview,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: kPrimary),
        items: List.generate(5, (i) => i + 1)
            .map((val) => DropdownMenuItem(
          value: val,
          child: Text(
            '⭐' * val + '  ($val)',
            style: GoogleFonts.lato(
                color:      kPrimaryDark,
                fontWeight: FontWeight.w600),
          ),
        ))
            .toList(),
        onChanged: (val) {
          if (val != null) {
            context.read<ReviewBloc>().add(SelectReviewEvent(val));
          }
        },
      ),
    );
  }

  Widget _employeeDropdown(
      BuildContext context, ReviewFormState state) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: state.employees
            .any((e) => e.Id == state.selectedEmpId)
            ? state.selectedEmpId
            : null,
        isExpanded: true,
        hint: Text('Select Employee',
            style: GoogleFonts.lato(color: Colors.grey)),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: kPrimary),
        items: state.employees
            .map((e) => DropdownMenuItem(
          value: e.Id,
          child: Text(
            e.AccountName,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
                color:      kPrimaryDark,
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
    );
  }

  Widget _buildDatePicker(
      BuildContext context, ReviewFormState state,
      {required bool isTablet}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 18 : 16,
        vertical:   isTablet ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color:         kAccent,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        border: Border.all(color: kPrimaryLight.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.calendar_today_rounded,
            color: kPrimary,
            size:  isTablet ? 22 : 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Date: ${DateFormat('yyyy-MM-dd').format(state.selectedDate)}',
            style: GoogleFonts.lato(
              color:      kPrimaryDark,
              fontWeight: FontWeight.w600,
              fontSize:   isTablet ? 15 : 14,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(Icons.edit_calendar_rounded,
                color: kPrimary,
                size:  isTablet ? 24 : 22),
            onPressed: () async {
              final picked = await showDatePicker(
                context:     context,
                initialDate: state.selectedDate,
                firstDate:   DateTime(2020),
                lastDate:    DateTime(2100),
              );
              if (picked != null) {
                context
                    .read<ReviewBloc>()
                    .add(SelectDateEvent(picked));
              }
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ReviewFormState state,
      {required bool isTablet}) {
    return Row(children: [
      // Save
      Expanded(
        child: ElevatedButton.icon(
          icon: state.saving
              ? SizedBox(
            width:  isTablet ? 20 : 18,
            height: isTablet ? 20 : 18,
            child: const CircularProgressIndicator(
                color: kWhite, strokeWidth: 2),
          )
              : Icon(Icons.save_rounded,
              color: kWhite,
              size:  isTablet ? 22 : 20),
          label: Text(
            state.saving ? "Saving..." : "Save",
            style: GoogleFonts.lato(
              color:      kWhite,
              fontWeight: FontWeight.bold,
              fontSize:   isTablet ? 15 : 14,
            ),
          ),
          onPressed: state.saving
              ? null
              : () {
            if (_formKey.currentState!.validate()) {
              context.read<ReviewBloc>().add(
                SaveReviewEvent(
                  shopName:   _shopCtrl.text.trim(),
                  mobileNo:   _mobileCtrl.text.trim(),
                  reviewMsg:  _reviewMsgCtrl.text.trim(),
                  existingId: widget.existingReview?.id,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12)),
            elevation: 0,
          ),
        ),
      ),

      const SizedBox(width: 12),

      // View
      Expanded(
        child: ElevatedButton.icon(
          icon: Icon(Icons.grid_view_rounded,
              color: kPrimary,
              size:  isTablet ? 22 : 20),
          label: Text("View",
              style: GoogleFonts.lato(
                color:      kPrimary,
                fontWeight: FontWeight.bold,
                fontSize:   isTablet ? 15 : 14,
              )),
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
            padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 14 : 12)),
            elevation: 0,
          ),
        ),
      ),
    ]);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool isTablet,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller:   controller,
      validator:    validator,
      keyboardType: keyboardType,
      maxLines:     maxLines,
      style: GoogleFonts.lato(
          color:    kPrimaryDark,
          fontSize: isTablet ? 15 : 14),
      decoration: InputDecoration(
        labelText:  label,
        labelStyle: GoogleFonts.lato(
            color:    Colors.grey[600],
            fontSize: isTablet ? 14 : 13),
        filled:    true,
        fillColor: kAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide:   BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide:
          const BorderSide(color: kPrimary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 16,
          vertical:   isTablet ? 16 : 14,
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required Widget child,
    required String label,
    required bool isTablet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
              fontSize:   isTablet ? 13 : 12,
              color:      Colors.grey[600],
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 14 : 12),
          decoration: BoxDecoration(
            color:         kAccent,
            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
            border: Border.all(
                color: kPrimaryLight.withOpacity(0.3)),
          ),
          child: child,
        ),
      ],
    );
  }
}

// ─── Info Panel (Tablet right column) ────────────────────────────────────────
class _InfoPanel extends StatelessWidget {
  final ReviewFormState state;
  const _InfoPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    // Selected employee name
    final empName = state.employees
        .where((e) => e.Id == state.selectedEmpId)
        .map((e) => e.AccountName)
        .firstOrNull ?? 'Not selected';

    final stars = state.selectedReview ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color:         Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:     kPrimary.withOpacity(0.07),
            blurRadius: 16,
            offset:    const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Row(children: [
            Container(
              width: 4, height: 22,
              decoration: BoxDecoration(
                color:         kPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Text('Review Preview',
                style: GoogleFonts.lato(
                  fontSize:   15,
                  fontWeight: FontWeight.bold,
                  color:      kPrimaryDark,
                )),
          ]),

          const SizedBox(height: 20),

          // Star rating display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimary, kPrimaryDark],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rating',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color:    Colors.white.withOpacity(0.75),
                    )),
                const SizedBox(height: 4),
                Text(
                  stars > 0 ? '⭐' * stars : 'Not selected',
                  style: GoogleFonts.lato(
                    fontSize:   22,
                    fontWeight: FontWeight.bold,
                    color:      Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Employee
          _previewRow(Icons.person_rounded,
              'Employee', empName),
          const SizedBox(height: 12),

          // Date
          _previewRow(Icons.calendar_today_rounded, 'Date',
              DateFormat('dd MMM yyyy')
                  .format(state.selectedDate)),
          const SizedBox(height: 12),

          // Tips
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:         kAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.lightbulb_rounded,
                      color: kPrimary, size: 16),
                  const SizedBox(width: 6),
                  Text('Tips',
                      style: GoogleFonts.lato(
                        fontSize:   12,
                        fontWeight: FontWeight.bold,
                        color:      kPrimaryDark,
                      )),
                ]),
                const SizedBox(height: 8),
                _tipRow('Fill all required fields before saving'),
                _tipRow('Select the correct employee'),
                _tipRow('Review message is optional'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color:         kAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimary, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color:    Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.lato(
                    fontSize:   14,
                    fontWeight: FontWeight.w700,
                    color:      kPrimaryDark,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: kPrimary, size: 13),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: GoogleFonts.lato(
                fontSize: 12,
                color:    Colors.grey[600],
              )),
        ),
      ]),
    );
  }
}