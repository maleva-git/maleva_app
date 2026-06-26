import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/colors/colors.dart' as colour;
import '../bloc/troubleshoot_bloc.dart';
import '../bloc/troubleshoot_event.dart';
import '../bloc/troubleshoot_state.dart';

/// Call this from anywhere — e.g. a drawer item, an app bar icon,
/// or a floating button — to open the "Report a Problem" sheet.
///
/// Example:
///   IconButton(
///     icon: Icon(Icons.bug_report_outlined),
///     onPressed: () => showTroubleshootSheet(context),
///   )
void showTroubleshootSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => TroubleshootBloc(),
      child: const _TroubleshootSheet(),
    ),
  );
}

class _TroubleshootSheet extends StatefulWidget {
  const _TroubleshootSheet();

  @override
  State<_TroubleshootSheet> createState() => _TroubleshootSheetState();
}

class _TroubleshootSheetState extends State<_TroubleshootSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colour.cWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: BlocConsumer<TroubleshootBloc, TroubleshootState>(
          listener: (context, state) {
            if (state.success) {
              // Close the sheet, then show a confirmation toast.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Report sent! Our team will look into it.",
                    style: GoogleFonts.dmSans(),
                  ),
                  backgroundColor: const Color(0xFF22A06B),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colour.cBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bug_report_outlined,
                          size: 20, color: colour.cRose),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Report a Problem",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colour.cText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "We'll send your recent activity along with this note "
                  "so our team can find and fix the issue faster.",
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    color: colour.cSub,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  onChanged: (v) =>
                      context.read<TroubleshootBloc>().add(TroubleshootNoteChanged(v)),
                  style: GoogleFonts.dmSans(fontSize: 13.5, color: colour.cText),
                  decoration: InputDecoration(
                    hintText: "What went wrong? (optional)\nE.g. \"Menu didn't load after login\"",
                    hintStyle: GoogleFonts.dmSans(fontSize: 13, color: colour.cSub),
                    filled: true,
                    fillColor: colour.cSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    state.errorMessage!,
                    style: GoogleFonts.dmSans(fontSize: 12, color: colour.cRose),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.sending
                        ? null
                        : () => context.read<TroubleshootBloc>().add(TroubleshootSubmitted()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.cBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: state.sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Send Report",
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
