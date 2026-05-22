import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/theme/palette.dart';
import '../../theme/tokens.dart';
import '../bloc/bluetooth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key, this.printData});

  /// When non-null the page auto-connects to the saved device and shows
  /// a spinner instead of the scan list — matches original PrintData behaviour.
  final List<BarcodePrintModel>? printData;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BluetoothBloc()
        ..add(BluetoothInitialized(autoConnect: printData != null)),
      child: _BluetoothView(isPrintMode: printData != null),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View
// ─────────────────────────────────────────────────────────────────────────────

class _BluetoothView extends StatelessWidget {
  const _BluetoothView({required this.isPrintMode});

  /// true  → auto-connect spinner mode (PrintData was passed)
  /// false → scan / device-list mode
  final bool isPrintMode;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BluetoothBloc, BluetoothState>(
      listener: _handleListener,
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: AppTokens.surfacePage,
          appBar: _buildAppBar(ctx, state),
          body: isPrintMode
              ? _buildAutoConnectBody(state)
              : _buildScanBody(ctx, state),
          floatingActionButton:
          isPrintMode ? null : _buildFAB(ctx, state),
        );
      },
    );
  }

  // ── Listener ──────────────────────────────────────────────────────────────

  void _handleListener(BuildContext ctx, BluetoothState state) {
    // Device saved → pop back to caller
    if (state.isSaved) {
      Navigator.of(ctx).pop();
      return;
    }

    // Show error snackbar
    if (state.status == BluetoothStatus.failure &&
        state.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        backgroundColor: Palette.redError,
        content: Text(state.errorMessage,
            style: GoogleFonts.lato(color: Palette.white)),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext ctx, BluetoothState state) {
    return AppBar(
      flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppTokens.headerGradient)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme:
      const IconThemeData(color: AppTokens.appBarIcon),
      title: Text(
        'Bluetooth',
        style: GoogleFonts.lato(
          color: AppTokens.appBarTitle,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      // Status indicator chip
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(child: _StatusChip(state: state)),
        ),
      ],
    );
  }

  // ── Auto-connect (print) mode ─────────────────────────────────────────────

  Widget _buildAutoConnectBody(BluetoothState state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitFoldingCube(
            color: Palette.redError,
            size: 35,
          ),
          const SizedBox(height: 16),
          Text(
            state.isConnecting
                ? 'Connecting to printer…'
                : 'Preparing print…',
            style: GoogleFonts.lato(
              color: AppTokens.textSecondary,
              fontSize: 14,
            ),
          ),
          if (state.selectedDevice != null) ...[
            const SizedBox(height: 8),
            Text(
              state.selectedDevice!.name,
              style: GoogleFonts.lato(
                color: AppTokens.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Scan mode ─────────────────────────────────────────────────────────────

  Widget _buildScanBody(
      BuildContext ctx, BluetoothState state) {
    if (!state.isBlueOn) return _BlueOffWidget();

    if (state.scanResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bluetooth_searching,
                size: 64,
                color: AppTokens.brandPrimary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              state.isScanning
                  ? 'Scanning for devices…'
                  : 'Tap SCAN to find devices',
              style: GoogleFonts.lato(
                color: AppTokens.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      itemCount: state.scanResults.length,
      itemBuilder: (_, i) => _DeviceRow(
        device: state.scanResults[i],
        isConnecting: state.isConnecting &&
            state.selectedDevice?.address ==
                state.scanResults[i].address,
        onConnect: () => ctx.read<BluetoothBloc>().add(
            BluetoothDeviceConnectRequested(state.scanResults[i])),
      ),
    );
  }

  // ── Floating action button ─────────────────────────────────────────────────

  Widget? _buildFAB(BuildContext ctx, BluetoothState state) {
    if (!state.isBlueOn) return null;

    return state.isScanning
        ? FloatingActionButton(
      backgroundColor: Palette.red,
      onPressed: () =>
          ctx.read<BluetoothBloc>().add(const BluetoothScanStopped()),
      child: const Icon(Icons.stop, color: Palette.white),
    )
        : FloatingActionButton.extended(
      backgroundColor: AppTokens.statusSuccess,
      onPressed: () =>
          ctx.read<BluetoothBloc>().add(const BluetoothScanStarted()),
      icon: const Icon(Icons.bluetooth_searching,
          color: Palette.white),
      label: Text('SCAN',
          style: GoogleFonts.lato(
              color: Palette.white,
              fontWeight: FontWeight.bold)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Device list row
// ─────────────────────────────────────────────────────────────────────────────

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.device,
    required this.isConnecting,
    required this.onConnect,
  });

  final BluetoothDevice device;
  final bool isConnecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      color: AppTokens.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTokens.surfaceCardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // ── Device icon ─────────────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTokens.brandPrimary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bluetooth,
                  color: AppTokens.brandPrimary, size: 20),
            ),
            const SizedBox(width: 12),

            // ── Name + address ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name.isNotEmpty
                        ? device.name
                        : 'Unknown Device',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.address,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Connect button ───────────────────────────────────────
            isConnecting
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppTokens.brandPrimary),
              ),
            )
                : OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: AppTokens.brandPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
              ),
              onPressed: onConnect,
              child: Text(
                'Connect',
                style: GoogleFonts.lato(
                  color: AppTokens.brandPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip shown in AppBar
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.state});
  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (state.status) {
      BluetoothStatus.connected      => ('Connected',    AppTokens.statusSuccess),
      BluetoothStatus.connectingToDevice => ('Connecting…', AppTokens.statusWarning),
      BluetoothStatus.disconnected   => ('Disconnected', AppTokens.statusDanger),
      BluetoothStatus.scanning       => ('Scanning',     AppTokens.planCobalt),
      BluetoothStatus.failure        => ('Error',        Palette.redError),
      _                              => ('Ready',        AppTokens.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.lato(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bluetooth off widget
// ─────────────────────────────────────────────────────────────────────────────

class _BlueOffWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bluetooth_disabled,
              size: 64, color: Palette.redError.withOpacity(0.7)),
          const SizedBox(height: 16),
          Text(
            'Bluetooth is turned off',
            style: GoogleFonts.lato(
              color: Palette.redError,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Please turn on Bluetooth to scan for devices',
            style: GoogleFonts.lato(
              color: AppTokens.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}