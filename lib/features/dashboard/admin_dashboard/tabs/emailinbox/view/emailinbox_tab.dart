import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../bloc/emailinbox_bloc.dart';
import '../bloc/emailinbox_event.dart';
import '../bloc/emailinbox_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;


// ── Entry Point ───────────────────────────────────────────────────────────────
class EmailPage extends StatelessWidget {
  const EmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmailBloc(context)..add(const LoadEmployeesEvent()),
      child: const _EmailBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _EmailBody extends StatelessWidget {
  const _EmailBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmailBloc, EmailState>(
      // ── Listener — side effects (dialogs, snackbars) ──
      listener: (context, state) async {
        if (state is EmailSaveSuccess) {
          await objfun.ConfirmationOK(
              'Updated Successfully:\n${state.message}', context);
          // Reload emails after save
          final bloc = context.read<EmailBloc>();
          final current = bloc.state;
          if (current is EmployeesLoaded &&
              current.selectedEmployee != null) {
            bloc.add(LoadEmailsEvent(current.selectedEmployee!.Id));
          }
        }

        if (state is EmailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      // ── Builder — UI ──────────────────────────────────
      builder: (context, state) {

        // ── Employees Loading ──
        if (state is EmployeesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: colour.kPrimary),
          );
        }

        // ── Error ──
        if (state is EmailError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(color: Colors.red, fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<EmailBloc>()
                      .add(const LoadEmployeesEvent()),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style:
                  ElevatedButton.styleFrom(backgroundColor: colour.kPrimary),
                ),
              ],
            ),
          );
        }

        // ── Employees Loaded ──
        if (state is EmployeesLoaded) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [

                // ── Employee Dropdown ──────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: colour.kAccent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: colour.kPrimaryLight.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EmployeeModel>(
                      isExpanded: true,
                      value: state.selectedEmployee,
                      hint: Text("Select Employee",
                          style: GoogleFonts.lato(color: Colors.grey)),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: colour.kPrimary),
                      items: state.employees.map((emp) {
                        return DropdownMenuItem(
                          value: emp,
                          child: Text(
                            emp.AccountName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.lato(
                                color: colour.kPrimaryDark,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<EmailBloc>()
                              .add(SelectEmployeeEvent(value));
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Emails List ────────────────────────────────────────────
                Expanded(
                  child: state.emailsLoading
                      ? const Center(
                    child:
                    CircularProgressIndicator(color: colour.kPrimary),
                  )
                      : state.emails.isEmpty
                      ? Center(
                    child: Text(
                      "No emails found.",
                      style: GoogleFonts.lato(
                          fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: state.emails.length,
                    itemBuilder: (context, index) {
                      final email = state.emails[index];
                      return _EmailCard(
                        email: email,
                        index: index,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // ── Save Button ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: state.saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: colour.kWhite, strokeWidth: 2),
                    )
                        : const Icon(Icons.save_rounded, color: colour.kWhite),
                    label: Text(
                      state.saving ? "Saving..." : "Save Emails",
                      style: GoogleFonts.lato(
                          color: colour.kWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: state.saving
                        ? null
                        : () async {
                      final confirm =
                      await objfun.ConfirmationMsgYesNo(
                        context,
                        "Do You Want to Update?",
                      );
                      if (!confirm) return;

                      final toSave = state.emails
                          .where((e) => e.isActive)
                          .toList();
                      if (toSave.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "No active emails selected to save"),
                          ),
                        );
                        return;
                      }
                      context
                          .read<EmailBloc>()
                          .add(const SaveEmailsEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.kPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ── Email Card ────────────────────────────────────────────────────────────────
class _EmailCard extends StatelessWidget {
  final EmailModel email;
  final int index;

  const _EmailCard({required this.email, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colour.kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colour.kPrimary.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Name + Date Row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    email.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colour.kPrimaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  email.receivedDate
                      .toLocal()
                      .toString()
                      .split('.')
                      .first,
                  style: GoogleFonts.lato(
                      color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Subject ──
            Text(
              email.subject,
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 4),

            // ── Sender ──
            Row(
              children: [
                const Icon(Icons.email_outlined,
                    size: 14, color: colour.kPrimaryLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    email.sender,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                        color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Divider(color: colour.kAccent, thickness: 1, height: 1),
            const SizedBox(height: 8),

            // ── Checkboxes ──
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _CheckboxChip(
                  label: "Active",
                  value: email.isActive,
                  activeColor: colour.kPrimary,
                  onChanged: (v) => context.read<EmailBloc>().add(
                    ToggleEmailActiveEvent(
                        index: index, value: v ?? false),
                  ),
                ),
                _CheckboxChip(
                  label: "Read",
                  value: email.isUnread,
                  activeColor: colour.kPrimaryLight,
                  onChanged: (v) => context.read<EmailBloc>().add(
                    ToggleEmailUnreadEvent(
                        index: index, value: v ?? false),
                  ),
                ),
                _CheckboxChip(
                  label: "Replied",
                  value: email.isReplied,
                  activeColor: Colors.green,
                  onChanged: (v) => context.read<EmailBloc>().add(
                    ToggleEmailRepliedEvent(
                        index: index, value: v ?? false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Checkbox Chip ─────────────────────────────────────────────────────────────
class _CheckboxChip extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool?> onChanged;

  const _CheckboxChip({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: value ? activeColor.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? activeColor.withOpacity(0.4) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: value ? activeColor : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}