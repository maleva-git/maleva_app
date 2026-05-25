import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/theme/palette.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/unreleasesmk_bloc.dart';
import '../bloc/unreleasesmk_event.dart';
import '../bloc/unreleasesmk_state.dart';


class UnReleaseSMKPage extends StatelessWidget {
  const UnReleaseSMKPage({super.key});

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (_) => sl<UnReleaseSMKBloc>()
          ..add(const UnReleaseSMKDataRequested()),
        child: const _UnReleaseSMKView(),
      );
  }
}
class _UnReleaseSMKView extends StatelessWidget {
  const _UnReleaseSMKView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: _buildAppBar(context),
      body: BlocConsumer<UnReleaseSMKBloc, UnReleaseSMKState>(
        listener: (context, state) {
          if (state.status == UnReleaseSMKStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Palette.redError,
                content: Text(
                  state.errorMessage,
                  style: GoogleFonts.lato(color: Palette.white),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) return _LoadingWidget();
          if (state.status == UnReleaseSMKStatus.failure) {
            return _ErrorWidget(
              message: state.errorMessage,
              onRetry: () => context
                  .read<UnReleaseSMKBloc>()
                  .add(const UnReleaseSMKDataRequested()),
            );
          }
          if (state.isEmpty) return const _EmptyWidget();
          return _buildBody(context, state);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppTokens.headerGradient),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'K8 UnRelease SMK',
        style: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: AppTokens.appBarTitle,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTokens.appBarIcon),
          tooltip: 'Refresh',
          onPressed: () => context
              .read<UnReleaseSMKBloc>()
              .add(const UnReleaseSMKRefreshRequested()),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, UnReleaseSMKState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;

        return RefreshIndicator(
          color: AppTokens.brandPrimary,
          backgroundColor: AppTokens.surfaceCard,
          onRefresh: () async {
            context
                .read<UnReleaseSMKBloc>()
                .add(const UnReleaseSMKRefreshRequested());
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: Column(
            children: [
              _SummaryBadge(count: state.unReleaseList.length),
              _ColumnHeader(isTablet: isTablet),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 12,
                    vertical: 8,
                  ),
                  itemCount: state.unReleaseList.length,
                  itemBuilder: (context, index) {
                    final item = state.unReleaseList[index];
                    final int days =
                        int.tryParse(item['DayCount']?.toString() ?? '0') ?? 0;
                    return _UnReleaseSMKCard(
                      index: index,
                      item: item,
                      bgColor: state.cardColor(index),
                      dayBadgeColor: state.dayCountColor(days),
                      isTablet: isTablet,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: AppTokens.headerGradient,
        boxShadow: [
          BoxShadow(
            color: Palette.brandGlow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 16, color: Palette.white),
          const SizedBox(width: 6),
          Text(
            'Total Unreleased: $count',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                color: Palette.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double fs = isTablet ? 13 : 11;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 12, vertical: 6),
      padding: EdgeInsets.symmetric(
          horizontal: 12, vertical: isTablet ? 10 : 7),
      decoration: BoxDecoration(
        color: AppTokens.invoiceHeaderStart,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _hdr('#', fs, TextAlign.center)),
          Expanded(flex: 3, child: _hdr('Bill No', fs, TextAlign.left)),
          Expanded(flex: 2, child: _hdr('Days', fs, TextAlign.left)),
          Expanded(flex: 3, child: _hdr('Remarks', fs, TextAlign.left)),
        ],
      ),
    );
  }

  Widget _hdr(String label, double size, TextAlign align) => Text(
    label,
    textAlign: align,
    style: GoogleFonts.lato(
      textStyle: TextStyle(
        color: Palette.white,
        fontWeight: FontWeight.bold,
        fontSize: size,
        letterSpacing: 0.4,
      ),
    ),
  );
}

/// Individual list card — 4 columns
class _UnReleaseSMKCard extends StatelessWidget {
  const _UnReleaseSMKCard({
    required this.index,
    required this.item,
    required this.bgColor,
    required this.dayBadgeColor,
    required this.isTablet,
  });

  final int index;
  final Map<String, dynamic> item;
  final Color bgColor;
  final Color dayBadgeColor;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double rowHeight = isTablet ? 52 : 44;
    final double fs = isTablet ? 13.5 : 12;

    final String billNo = item['BillNoDisplay']?.toString() ?? '-';
    final String dayCount = item['DayCount']?.toString() ?? '-';
    final String remarks = item['Remarks']?.toString() ?? '-';

    return SizedBox(
      height: rowHeight,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 2),
        elevation: 1,
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(
              color: AppTokens.surfaceCardBorder, width: 0.6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            // TODO: navigate to detail or show dialog
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // ── S.No ──────────────────────────────────
                Expanded(
                  flex: 1,
                  child: _cell(
                    (index + 1).toString(),
                    fs,
                    AppTokens.textSecondary,
                    TextAlign.center,
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: _cell(
                    billNo,
                    fs,
                    AppTokens.textPrimary,
                    TextAlign.left,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: dayBadgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: dayBadgeColor.withOpacity(0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        dayCount,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: dayBadgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: fs - 0.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: _cell(
                    remarks,
                    fs - 0.5,
                    AppTokens.textMuted,
                    TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(
      String text,
      double size,
      Color color,
      TextAlign align,
      ) =>
      Text(
        text,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: size,
            letterSpacing: 0.2,
          ),
        ),
      );
}

class _LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor:
            AlwaysStoppedAnimation<Color>(AppTokens.brandPrimary),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading K8 SMK bills…',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                color: AppTokens.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64, color: Palette.greenEco.withOpacity(0.7)),
          const SizedBox(height: 12),
          Text(
            'No unreleased K8 SMK bills',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                color: AppTokens.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All K8 SMK bills are released',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                  color: AppTokens.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: Palette.redError),
            const SizedBox(height: 12),
            Text(
              'Failed to load data',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  color: AppTokens.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: AppTokens.textMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                foregroundColor: Palette.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}