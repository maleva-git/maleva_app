import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Employee.dart';

import '../bloc/forwardingsalary_bloc.dart';
import '../bloc/forwardingsalary_event.dart';
import '../bloc/forwardingsalary_state.dart';


// ─── Design Tokens ────────────────────────────────────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class ForwardingSalaryUpdate extends StatelessWidget {
  const ForwardingSalaryUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ForwardingSalaryBloc()..add(ForwardingSalaryStarted()),
      child: const _ForwardingSalaryPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _ForwardingSalaryPage extends StatelessWidget {
  const _ForwardingSalaryPage();

  @override
  Widget build(BuildContext context) {
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<ForwardingSalaryBloc, ForwardingSalaryState>(
      listener: (context, state) async {
        if (state is ForwardingSalarySaveSuccess) {
          await objfun.ConfirmationOK('Saved Successfully', context);
        }
        if (state is ForwardingSalaryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: const Color(0xFFB33040),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: kPageBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<ForwardingSalaryBloc, ForwardingSalaryState>(
            builder: (context, state) {
              if (state is ForwardingSalaryInitial ||
                  state is ForwardingSalaryLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is ForwardingSalaryLoaded) {
                return GestureDetector(
                  onTap: () => context
                      .read<ForwardingSalaryBloc>()
                      .add(ForwardingSalaryOverlayDismissed()),
                  child: _ForwardingSalaryBody(state: state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, String userName) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 62,
      flexibleSpace:
      Container(decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('F/S Update',
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(userName,
              style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: _AppBarButton(
            label: 'Update',
            onPressed: () {
              final s = context.read<ForwardingSalaryBloc>().state;
              if (s is! ForwardingSalaryLoaded) return;

              if (s.sealEmpName.isEmpty ||
                  s.breakEmpName.isEmpty ||
                  s.rtiText.isEmpty) {
                objfun.toastMsg(
                    'Please fill all required fields', '', context);
                return;
              }
              objfun
                  .ConfirmationMsgYesNo(
                  context, 'Are you sure to Save?')
                  .then((ok) {
                if (ok == true) {
                  context
                      .read<ForwardingSalaryBloc>()
                      .add(ForwardingSalarySaveRequested());
                }
              });
            },
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body — LayoutBuilder for mobile/tablet ───────────────────────────────────
class _ForwardingSalaryBody extends StatelessWidget {
  final ForwardingSalaryLoaded state;
  const _ForwardingSalaryBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        // Tablet: centre content with proportional horizontal padding
        final hPad = isTablet ? constraints.maxWidth * 0.12 : 14.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── BillType radio ────────────────────────────────────
              _BillTypeRow(
                  billType: state.billType, isTablet: isTablet),
              SizedBox(height: isTablet ? 16 : 12),

              // ── RTI No field + autocomplete ───────────────────────
              _RtiField(
                  state: state, isTablet: isTablet),
              SizedBox(height: isTablet ? 16 : 12),

              // ── Tablet: 2-column layout for emp fields ────────────
              isTablet
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Seal By', isTablet),
                        const SizedBox(height: 6),
                        _EmpSearchField(
                          hint: 'Seal By',
                          value: state.sealEmpName,
                          isTablet: isTablet,
                          onSearch: () =>
                              _pickSealEmp(context),
                          onClear: () => context
                              .read<ForwardingSalaryBloc>()
                              .add(ForwardingSalarySealEmpCleared()),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Salary 1', isTablet),
                        const SizedBox(height: 6),
                        _FSTextField(
                          hint: 'Salary 1',
                          value: state.salary1,
                          isTablet: isTablet,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => context
                              .read<ForwardingSalaryBloc>()
                              .add(ForwardingSalarySalary1Changed(v)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: constraints.maxWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Break Seal', isTablet),
                        const SizedBox(height: 6),
                        _EmpSearchField(
                          hint: 'Break Seal',
                          value: state.breakEmpName,
                          isTablet: isTablet,
                          onSearch: () =>
                              _pickBreakEmp(context),
                          onClear: () => context
                              .read<ForwardingSalaryBloc>()
                              .add(ForwardingSalaryBreakEmpCleared()),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Salary 2', isTablet),
                        const SizedBox(height: 6),
                        _FSTextField(
                          hint: 'Salary 2',
                          value: state.salary2,
                          isTablet: isTablet,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => context
                              .read<ForwardingSalaryBloc>()
                              .add(ForwardingSalarySalary2Changed(v)),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Seal By ─────────────────────────────────
                  _FieldLabel('Seal By', isTablet),
                  const SizedBox(height: 6),
                  _EmpSearchField(
                    hint: 'Seal By',
                    value: state.sealEmpName,
                    isTablet: isTablet,
                    onSearch: () => _pickSealEmp(context),
                    onClear: () => context
                        .read<ForwardingSalaryBloc>()
                        .add(ForwardingSalarySealEmpCleared()),
                  ),
                  const SizedBox(height: 12),

                  // ── Salary 1 ─────────────────────────────────
                  _FieldLabel('Salary 1', isTablet),
                  const SizedBox(height: 6),
                  _FSTextField(
                    hint: 'Salary',
                    value: state.salary1,
                    isTablet: isTablet,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => context
                        .read<ForwardingSalaryBloc>()
                        .add(ForwardingSalarySalary1Changed(v)),
                  ),
                  const SizedBox(height: 12),

                  // ── Break Seal ───────────────────────────────
                  _FieldLabel('Break Seal', isTablet),
                  const SizedBox(height: 6),
                  _EmpSearchField(
                    hint: 'Break Seal',
                    value: state.breakEmpName,
                    isTablet: isTablet,
                    onSearch: () => _pickBreakEmp(context),
                    onClear: () => context
                        .read<ForwardingSalaryBloc>()
                        .add(ForwardingSalaryBreakEmpCleared()),
                  ),
                  const SizedBox(height: 12),

                  // ── Salary 2 ─────────────────────────────────
                  _FieldLabel('Salary 2', isTablet),
                  const SizedBox(height: 6),
                  _FSTextField(
                    hint: 'Salary',
                    value: state.salary2,
                    isTablet: isTablet,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => context
                        .read<ForwardingSalaryBloc>()
                        .add(ForwardingSalarySalary2Changed(v)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Employee pickers ────────────────────────────────────────────────────────
  Future<void> _pickSealEmp(BuildContext context) async {
    await OnlineApi.SelectEmployee(context, '', 'Operation');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const Employee(Searchby: 1, SearchId: 0)),
    ).then((_) {
      final sel = objfun.SelectEmployeeList;
      if (sel.Id != 0) {
        context.read<ForwardingSalaryBloc>().add(
            ForwardingSalarySealEmpChanged(
                empId: sel.Id, empName: sel.AccountName));
        objfun.SelectEmployeeList = EmployeeModel.Empty();
      }
    });
  }

  Future<void> _pickBreakEmp(BuildContext context) async {
    await OnlineApi.SelectEmployee(context, '', 'Operation');
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const Employee(Searchby: 1, SearchId: 0)),
    ).then((_) {
      final sel = objfun.SelectEmployeeList;
      if (sel.Id != 0) {
        context.read<ForwardingSalaryBloc>().add(
            ForwardingSalaryBreakEmpChanged(
                empId: sel.Id, empName: sel.AccountName));
        objfun.SelectEmployeeList = EmployeeModel.Empty();
      }
    });
  }
}

// ─── RTI No field + inline autocomplete ──────────────────────────────────────
class _RtiField extends StatefulWidget {
  final ForwardingSalaryLoaded state;
  final bool isTablet;

  const _RtiField({required this.state, required this.isTablet});

  @override
  State<_RtiField> createState() => _RtiFieldState();
}

class _RtiFieldState extends State<_RtiField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.state.rtiText);
  }

  @override
  void didUpdateWidget(_RtiField old) {
    super.didUpdateWidget(old);
    if (widget.state.rtiText != _ctrl.text) {
      _ctrl.text = widget.state.rtiText;
      _ctrl.selection =
          TextSelection.collapsed(offset: widget.state.rtiText.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final isTablet = widget.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel('RTI No', isTablet),
        const SizedBox(height: 6),

        // TextField
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          style: GoogleFonts.lato(
              color: kTextDark,
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
          decoration: InputDecoration(
            hintText: 'RTI No',
            hintStyle: GoogleFonts.lato(
                color: kTextMuted,
                fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
            filled: true,
            fillColor: kDetailBg,
            prefixIcon: const Icon(Icons.tag_rounded,
                color: kHeaderGradEnd, size: 20),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: kTextMuted, size: 18),
              onPressed: () {
                _ctrl.clear();
                context
                    .read<ForwardingSalaryBloc>()
                    .add(ForwardingSalaryRtiTextChanged(''));
              },
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: kCardBorder, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: kHeaderGradEnd, width: 1.5),
            ),
          ),
          onChanged: (v) => context
              .read<ForwardingSalaryBloc>()
              .add(ForwardingSalaryRtiTextChanged(v)),
        ),

        // ── Inline autocomplete dropdown ───────────────────────────
        if (s.rtiSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kCardBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: kHeaderGradStart.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: s.rtiSuggestions.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: kDetailBg),
              itemBuilder: (ctx, i) {
                final item = s.rtiSuggestions[i];
                final cnum = item['CNumber'].toString();
                return InkWell(
                  onTap: () => context
                      .read<ForwardingSalaryBloc>()
                      .add(ForwardingSalaryRtiSelected(
                      saleOrderId: item['Id'], rtiNo: cnum)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 16, color: kHeaderGradEnd),
                        const SizedBox(width: 10),
                        Text(cnum,
                            style: GoogleFonts.lato(
                                color: kTextDark,
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet
                                    ? objfun.FontLow + 1
                                    : objfun.FontLow)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // No result hint
        if (s.rtiSuggestions.isEmpty &&
            s.rtiText.isNotEmpty &&
            s.saleOrderId == 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: kTextMuted),
                const SizedBox(width: 6),
                Text('No matching RTI numbers',
                    style: GoogleFonts.lato(
                        color: kTextMuted, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Bill Type Radio Row ──────────────────────────────────────────────────────
class _BillTypeRow extends StatelessWidget {
  final String billType;
  final bool isTablet;

  const _BillTypeRow({required this.billType, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RadioOption(
            label: 'MY',
            value: '0',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) => context
                .read<ForwardingSalaryBloc>()
                .add(ForwardingSalaryBillTypeChanged(v)),
          ),
          SizedBox(width: isTablet ? 40 : 24),
          _RadioOption(
            label: 'TR',
            value: '1',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) => context
                .read<ForwardingSalaryBloc>()
                .add(ForwardingSalaryBillTypeChanged(v)),
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final bool isTablet;
  final void Function(String) onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.isTablet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isTablet ? 22 : 18,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kHeaderGradEnd : kCardBorder,
                  width: selected ? 0 : 1.5,
                ),
                gradient: selected ? kGradient : null,
              ),
              child: selected
                  ? const Icon(Icons.circle, size: 10, color: Colors.white)
                  : null,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              label,
              style: GoogleFonts.lato(
                color: selected ? kHeaderGradStart : kTextMid,
                fontWeight: FontWeight.w700,
                fontSize:
                isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Reusable Widgets ──────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const _FieldLabel(this.text, this.isTablet);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.lato(
            color: kTextMid,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow));
  }
}

class _EmpSearchField extends StatelessWidget {
  final String hint;
  final String value;
  final bool isTablet;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _EmpSearchField({
    required this.hint,
    required this.value,
    required this.isTablet,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: value.isEmpty ? onSearch : onClear,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: GoogleFonts.lato(
                  color: value.isEmpty ? kTextMuted : kTextDark,
                  fontWeight:
                  value.isEmpty ? FontWeight.w500 : FontWeight.w600,
                  fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              value.isNotEmpty ? Icons.close_rounded : Icons.search_rounded,
              size: 20,
              color: kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _FSTextField extends StatefulWidget {
  final String hint;
  final String value;
  final bool isTablet;
  final TextInputType keyboardType;
  final void Function(String) onChanged;

  const _FSTextField({
    required this.hint,
    required this.value,
    required this.isTablet,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  State<_FSTextField> createState() => _FSTextFieldState();
}

class _FSTextFieldState extends State<_FSTextField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_FSTextField old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.text = widget.value;
      _ctrl.selection =
          TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.done,
      onChanged: widget.onChanged,
      style: GoogleFonts.lato(
          color: kTextDark,
          fontWeight: FontWeight.w600,
          fontSize: widget.isTablet ? objfun.FontLow + 1 : objfun.FontLow),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: GoogleFonts.lato(
            color: kTextMuted,
            fontSize:
            widget.isTablet ? objfun.FontLow + 1 : objfun.FontLow),
        filled: true,
        fillColor: kDetailBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kCardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: kHeaderGradEnd, width: 1.5),
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _AppBarButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(label,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: objfun.FontMedium)),
          ),
        ),
      ),
    );
  }
}