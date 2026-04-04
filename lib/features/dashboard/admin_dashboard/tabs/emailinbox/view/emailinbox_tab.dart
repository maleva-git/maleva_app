import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../core/theme/tokens.dart';
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
      create: (_) =>
      EmailBloc(context)..add(const LoadEmployeesEvent()),
      child: const _EmailBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _EmailBody extends StatelessWidget {
  const _EmailBody();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<EmailBloc, EmailState>(
      listener: (context, state) async {
        if (state is EmailSaveSuccess) {
          await objfun.ConfirmationOK(
              'Updated Successfully:\n${state.message}', context);
          final bloc    = context.read<EmailBloc>();
          final current = bloc.state;
          if (current is EmployeesLoaded &&
              current.selectedEmployee != null) {
            bloc.add(LoadEmailsEvent(current.selectedEmployee!.Id));
          }
        }
        if (state is EmailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:         Text(state.message),
                backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is EmployeesLoading) {
          return const Center(
            child:
            CircularProgressIndicator(color: AppTokens.brandGradientStart),
          );
        }

        if (state is EmailError) {
          return _ErrorState(isTablet: isTablet);
        }

        if (state is EmployeesLoaded) {
          return isTablet
              ? _buildTabletLayout(context, state)
              : _buildMobileLayout(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, EmployeesLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (280px) — Title + Dropdown + Save button
          SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(children: [
                  Container(
                    width: 4, height: 30,
                    decoration: BoxDecoration(
                      color: AppTokens.brandGradientStart,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('EMAIL',
                      style: GoogleFonts.lato(
                        fontSize:      20,
                        fontWeight:    FontWeight.bold,
                        color:         AppTokens.brandDark,
                        letterSpacing: 1.2,
                      )),
                ]),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text('Inbox Management',
                      style: GoogleFonts.lato(
                        fontSize:   14,
                        color:      AppTokens.brandMid,
                        fontWeight: FontWeight.w500,
                      )),
                ),
                const SizedBox(height: 20),

                // Dropdown
                _EmployeeDropdown(state: state, isTablet: true),
                const SizedBox(height: 16),

                // Email count badge (when loaded)
                if (state.emails.isNotEmpty)
                  _CountBadge(count: state.emails.length),

                const Spacer(),

                // Save button at bottom of left panel
                _SaveButton(state: state, isTablet: true),
                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT — Email list
          Expanded(
            child: state.emailsLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppTokens.brandGradientStart))
                : state.emails.isEmpty
                ? _EmptyState(isTablet: true)
                : ListView.builder(
              itemCount: state.emails.length,
              itemBuilder: (context, index) =>
                  _EmailCard(
                    email:    state.emails[index],
                    index:    index,
                    isTablet: true,
                  ),
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
      BuildContext context, EmployeesLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        _EmployeeDropdown(state: state, isTablet: false),
        const SizedBox(height: 16),

        Expanded(
          child: state.emailsLoading
              ? const Center(
              child: CircularProgressIndicator(
                  color: AppTokens.brandGradientStart))
              : state.emails.isEmpty
              ? _EmptyState(isTablet: false)
              : ListView.builder(
            itemCount: state.emails.length,
            itemBuilder: (context, index) =>
                _EmailCard(
                  email:    state.emails[index],
                  index:    index,
                  isTablet: false,
                ),
          ),
        ),

        const SizedBox(height: 8),
        _SaveButton(state: state, isTablet: false),
      ]),
    );
  }
}

// ─── Employee Dropdown ────────────────────────────────────────────────────────
class _EmployeeDropdown extends StatelessWidget {
  final EmployeesLoaded state;
  final bool isTablet;
  const _EmployeeDropdown(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:         AppTokens.brandLight,
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        border: Border.all(
            color: AppTokens.brandMid.withOpacity(0.3)),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EmployeeModel>(
          isExpanded: true,
          value:      state.selectedEmployee,
          hint: Text("Select Employee",
              style: GoogleFonts.lato(
                color:    Colors.grey,
                fontSize: isTablet ? 15 : 14,
              )),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTokens.brandGradientStart,
              size:  isTablet ? 24 : 22),
          items: state.employees.map((emp) {
            return DropdownMenuItem(
              value: emp,
              child: Text(
                emp.AccountName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color:      AppTokens.brandDark,
                  fontWeight: FontWeight.w600,
                  fontSize:   isTablet ? 15 : 14,
                ),
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
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     AppTokens.brandGradientStart.withOpacity(0.28),
            blurRadius: 16,
            offset:    const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colour.kWhite.withOpacity(0.20),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.email_rounded,
              color: colour.kWhite, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Emails',
                style: GoogleFonts.lato(
                  fontSize:   12,
                  color:      colour.kWhite.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                )),
            Text('$count',
                style: GoogleFonts.lato(
                  fontSize:   28,
                  color:      colour.kWhite,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ]),
    );
  }
}

// ─── Save Button ──────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final EmployeesLoaded state;
  final bool isTablet;
  const _SaveButton(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: state.saving
            ? SizedBox(
          width:  isTablet ? 20 : 18,
          height: isTablet ? 20 : 18,
          child: const CircularProgressIndicator(
              color: colour.kWhite, strokeWidth: 2),
        )
            : Icon(Icons.save_rounded,
            color: colour.kWhite,
            size:  isTablet ? 22 : 20),
        label: Text(
          state.saving ? "Saving..." : "Save Emails",
          style: GoogleFonts.lato(
            color:      colour.kWhite,
            fontSize:   isTablet ? 16 : 15,
            fontWeight: FontWeight.bold,
          ),
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
          backgroundColor: AppTokens.brandGradientStart,
          padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Email Card ───────────────────────────────────────────────────────────────
class _EmailCard extends StatelessWidget {
  final EmailModel email;
  final int index;
  final bool isTablet;

  const _EmailCard({
    required this.email,
    required this.index,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 10 : 8),
      decoration: BoxDecoration(
        color:         colour.kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:     AppTokens.brandGradientStart.withOpacity(0.07),
            blurRadius: 10,
            offset:    const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + Date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    email.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize:   isTablet ? 17 : 16,
                      color:      AppTokens.brandDark,
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
                    color:    Colors.grey[500],
                    fontSize: isTablet ? 12 : 11,
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 8 : 6),

            // Subject
            Text(
              email.subject,
              style: GoogleFonts.lato(
                fontSize:   isTablet ? 16 : 15,
                fontWeight: FontWeight.w600,
                color:      Colors.black87,
              ),
            ),

            SizedBox(height: isTablet ? 6 : 4),

            // Sender
            Row(children: [
              Icon(Icons.email_outlined,
                  size:  isTablet ? 16 : 14,
                  color: AppTokens.brandMid),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  email.sender,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    color:    Colors.grey[600],
                    fontSize: isTablet ? 14 : 13,
                  ),
                ),
              ),
            ]),

            SizedBox(height: isTablet ? 14 : 12),

            Divider(color: AppTokens.brandLight, thickness: 1, height: 1),

            SizedBox(height: isTablet ? 10 : 8),

            // Checkboxes
            Wrap(
              spacing:    isTablet ? 14 : 12,
              runSpacing: isTablet ? 6  : 4,
              children: [
                _CheckboxChip(
                  label:       "Active",
                  value:       email.isActive,
                  activeColor: AppTokens.brandGradientStart,
                  isTablet:    isTablet,
                  onChanged: (v) =>
                      context.read<EmailBloc>().add(
                        ToggleEmailActiveEvent(
                            index: index, value: v ?? false),
                      ),
                ),
                _CheckboxChip(
                  label:       "Read",
                  value:       email.isUnread,
                  activeColor: AppTokens.brandMid,
                  isTablet:    isTablet,
                  onChanged: (v) =>
                      context.read<EmailBloc>().add(
                        ToggleEmailUnreadEvent(
                            index: index, value: v ?? false),
                      ),
                ),
                _CheckboxChip(
                  label:       "Replied",
                  value:       email.isReplied,
                  activeColor: Colors.green,
                  isTablet:    isTablet,
                  onChanged: (v) =>
                      context.read<EmailBloc>().add(
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

// ─── Checkbox Chip ────────────────────────────────────────────────────────────
class _CheckboxChip extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool?> onChanged;
  final bool isTablet;

  const _CheckboxChip({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 10 : 8,
        vertical:   isTablet ? 3  : 2,
      ),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value
              ? activeColor.withOpacity(0.4)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width:  isTablet ? 26 : 24,
            height: isTablet ? 26 : 24,
            child: Checkbox(
              value:                 value,
              onChanged:             onChanged,
              activeColor:           activeColor,
              materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize:   isTablet ? 14 : 13,
              fontWeight: FontWeight.w600,
              color:
              value ? activeColor : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final bool isTablet;
  const _ErrorState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              color: Colors.red,
              size:  isTablet ? 60 : 48),
          SizedBox(height: isTablet ? 16 : 12),
          Text("Something went wrong",
              style: GoogleFonts.lato(
                  color:    Colors.red,
                  fontSize: isTablet ? 16 : 14)),
          SizedBox(height: isTablet ? 20 : 16),
          ElevatedButton.icon(
            onPressed: () => context
                .read<EmailBloc>()
                .add(const LoadEmployeesEvent()),
            icon:  Icon(Icons.refresh,
                size: isTablet ? 20 : 18),
            label: Text("Retry",
                style: GoogleFonts.lato(
                    fontSize: isTablet ? 15 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandGradientStart,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 20,
                vertical:   isTablet ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isTablet;
  const _EmptyState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No emails found.",
          style: GoogleFonts.lato(
              fontSize: isTablet ? 18 : 16,
              color:    Colors.grey)),
    );
  }
}