import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/Transaction/SaleOrderDetails.dart';
import '../bloc/viewsaleorder_bloc.dart';
import '../bloc/viewsaleorder_event.dart';
import '../bloc/viewsaleorder_state.dart';


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

// ─── Breakpoint ───────────────────────────────────────────────────────────────
// <= 600 → mobile layout, > 600 → tablet layout
const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class GetJobNoPage extends StatelessWidget {
  const GetJobNoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetJobNoBloc()..add(GetJobNoStarted()),
      child: const _GetJobNoPageView(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _GetJobNoPageView extends StatelessWidget {
  const _GetJobNoPageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetJobNoBloc, GetJobNoState>(
      listener: (context, state) async {
        if (state is GetJobNoNavigateToDetails) {
          if (state.jobNo == 0 && state.saleOrderId == 0) {
            objfun.toastMsg('Enter Job No', '', context);
            return;
          }
          await OnlineApi.EditSalesOrder(
              context, state.saleOrderId, state.jobNo);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaleOrderDetails(
                SaleDetails: null,
                SaleMaster: objfun.SaleEditMasterList,
              ),
            ),
          );
        }
        if (state is GetJobNoError) {
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
          appBar: _buildAppBar(context),
          body: BlocBuilder<GetJobNoBloc, GetJobNoState>(
            builder: (context, state) {
              if (state is GetJobNoInitial || state is GetJobNoLoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is GetJobNoLoaded) {
                return _GetJobNoBody(state: state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      // Use LayoutBuilder inside flexibleSpace for adaptive height
      toolbarHeight: 62,
      flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Get Job No',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          letterSpacing: 0.3,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body — uses LayoutBuilder for mobile/tablet ──────────────────────────────
class _GetJobNoBody extends StatelessWidget {
  final GetJobNoLoaded state;
  const _GetJobNoBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;

        // Tablet: center card with max width + horizontal padding
        // Mobile: full width with padding
        return GestureDetector(
          onTap: () =>
              context.read<GetJobNoBloc>().add(GetJobNoOverlayDismissed()),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? constraints.maxWidth * 0.2 : 20,
                  vertical: 24,
                ),
                child: _JobNoCard(state: state, isTablet: isTablet),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Main Card ────────────────────────────────────────────────────────────────
class _JobNoCard extends StatelessWidget {
  final GetJobNoLoaded state;
  final bool isTablet;

  const _JobNoCard({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Gradient header strip ─────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: isTablet ? 16 : 14,
              ),
              decoration: const BoxDecoration(gradient: kGradient),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Job Number Lookup',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 16 : 15,
                    ),
                  ),
                ],
              ),
            ),

            // ── Card body ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Bill Type radios ──────────────────────────────
                  _BillTypeRow(
                      billType: state.billType, isTablet: isTablet),
                  SizedBox(height: isTablet ? 20 : 16),

                  // ── Job No field + suggestions ────────────────────
                  _JobNoField(state: state, isTablet: isTablet),
                  SizedBox(height: isTablet ? 24 : 18),

                  // ── Action buttons ────────────────────────────────
                  _ActionButtons(isTablet: isTablet, jobNoText: state.jobNoText),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final labelStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── MY ──
          _RadioOption(
            label: 'MY',
            value: '0',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) {
              context.read<GetJobNoBloc>().add(GetJobNoBillTypeChanged(v));
            },
          ),
          SizedBox(width: isTablet ? 32 : 20),
          // ── TR ──
          _RadioOption(
            label: 'TR',
            value: '1',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) {
              context.read<GetJobNoBloc>().add(GetJobNoBillTypeChanged(v));
            },
          ),
        ],
      ),
    );
  }
}

// ─── Single Radio Option ──────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            // Custom radio circle
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
                  ? const Icon(Icons.circle,
                  size: 10, color: Colors.white)
                  : null,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              label,
              style: GoogleFonts.lato(
                color: selected ? kHeaderGradStart : kTextMid,
                fontWeight: FontWeight.w700,
                fontSize: isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Job No Field + Inline Autocomplete Dropdown ──────────────────────────────
class _JobNoField extends StatefulWidget {
  final GetJobNoLoaded state;
  final bool isTablet;

  const _JobNoField({required this.state, required this.isTablet});

  @override
  State<_JobNoField> createState() => _JobNoFieldState();
}

class _JobNoFieldState extends State<_JobNoField> {
  final _controller = TextEditingController();

  @override
  void didUpdateWidget(_JobNoField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when suggestion selected from bloc
    if (widget.state.jobNoText != _controller.text) {
      _controller.text = widget.state.jobNoText;
      _controller.selection = TextSelection.collapsed(
          offset: widget.state.jobNoText.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = widget.isTablet;
    final suggestions = widget.state.suggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Job No',
          style: GoogleFonts.lato(
            color: kTextMid,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
          ),
        ),
        const SizedBox(height: 6),

        // TextField
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.lato(
            color: kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
          ),
          decoration: InputDecoration(
            hintText: 'Enter Job No',
            hintStyle: GoogleFonts.lato(
                color: kTextMuted,
                fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
            filled: true,
            fillColor: kDetailBg,
            prefixIcon: const Icon(Icons.tag_rounded,
                color: kHeaderGradEnd, size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: kTextMuted, size: 18),
              onPressed: () {
                _controller.clear();
                context
                    .read<GetJobNoBloc>()
                    .add(GetJobNoTextChanged(''));
              },
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kCardBorder, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: kHeaderGradEnd, width: 1.5),
            ),
          ),
          onChanged: (v) {
            context.read<GetJobNoBloc>().add(GetJobNoTextChanged(v));
          },
        ),

        // ── Inline suggestions dropdown ────────────────────────────────
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kCardBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: kHeaderGradStart.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, color: kDetailBg, indent: 14, endIndent: 14),
              itemBuilder: (ctx, i) {
                final item = suggestions[i];
                final jobNo = item['CNumber'].toString();
                final id    = item['Id'];
                return InkWell(
                  onTap: () {
                    context.read<GetJobNoBloc>().add(
                      GetJobNoSuggestionSelected(
                          saleOrderId: id, jobNo: jobNo),
                    );
                  },
                  borderRadius: i == 0
                      ? const BorderRadius.vertical(
                      top: Radius.circular(12))
                      : i == suggestions.length - 1
                      ? const BorderRadius.vertical(
                      bottom: Radius.circular(12))
                      : BorderRadius.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline_rounded,
                            size: 16, color: kHeaderGradEnd),
                        const SizedBox(width: 10),
                        Text(
                          jobNo,
                          style: GoogleFonts.lato(
                            color: kTextDark,
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet
                                ? objfun.FontLow + 1
                                : objfun.FontLow,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // No results hint
        if (suggestions.isEmpty &&
            widget.state.jobNoText.isNotEmpty &&
            widget.state.saleOrderId == 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: kTextMuted),
                const SizedBox(width: 6),
                Text(
                  'No matching job numbers found',
                  style: GoogleFonts.lato(
                      color: kTextMuted, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final bool isTablet;
  final String jobNoText;

  const _ActionButtons(
      {required this.isTablet, required this.jobNoText});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On very narrow screens, stack buttons vertically
        final stackButtons = constraints.maxWidth < 260;

        final viewBtn = _GradientButton(
          label: 'View',
          icon: Icons.arrow_circle_right_outlined,
          isTablet: isTablet,
          onPressed: () {
            if (jobNoText.isEmpty) {
              objfun.toastMsg('Enter Job No', '', context);
              return;
            }
            context.read<GetJobNoBloc>().add(GetJobNoViewRequested());
          },
        );

        final closeBtn = _OutlineButton(
          label: 'Close',
          icon: Icons.close_rounded,
          isTablet: isTablet,
          onPressed: () => Navigator.pop(context),
        );

        if (stackButtons) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              viewBtn,
              const SizedBox(height: 10),
              closeBtn,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: viewBtn),
            SizedBox(width: isTablet ? 24 : 16),
            Flexible(child: closeBtn),
          ],
        );
      },
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isTablet;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.isTablet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 28 : 20,
              vertical: isTablet ? 13 : 11,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize:
                    isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon,
                    color: Colors.white,
                    size: isTablet ? 22 : 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isTablet;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.isTablet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kChipBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 28 : 20,
              vertical: isTablet ? 13 : 11,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    color: kHeaderGradStart,
                    fontWeight: FontWeight.w700,
                    fontSize:
                    isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon,
                    color: kHeaderGradStart,
                    size: isTablet ? 22 : 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}