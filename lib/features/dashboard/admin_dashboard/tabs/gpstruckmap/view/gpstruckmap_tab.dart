import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../bloc/gpstruckmap_bloc.dart';
import '../bloc/gpstruckmap_event.dart';
import '../bloc/gpstruckmap_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Entry widget — creates the BlocProvider, matches your existing tab pattern
//  e.g. const InvoiceTab(), const SpeedingScreen(), const EngineHoursPage()
// ─────────────────────────────────────────────────────────────────────────────
class GpsTruckMapPage extends StatelessWidget {
  const GpsTruckMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GpsTruckMapBloc()..add(const LoadTruckPositions()),
      child: const _GpsTruckMapView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Main view
// ─────────────────────────────────────────────────────────────────────────────
class _GpsTruckMapView extends StatefulWidget {
  const _GpsTruckMapView();

  @override
  State<_GpsTruckMapView> createState() => _GpsTruckMapViewState();
}

class _GpsTruckMapViewState extends State<_GpsTruckMapView> {
  final MapController _mapController = MapController();

  // Port Klang, Malaysia — default center (matches Maleva's base)
  static const LatLng _kDefaultCenter = LatLng(3.0000, 101.3900);
  static const double _kDefaultZoom   = 10.0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GpsTruckMapBloc, GpsTruckMapState>(
      listener: (context, state) {
        if (state is GpsTruckMapError) {
          objfun.msgshow(
            state.message, '',
            colour.kWhite, AppTokens.brandGradientStart, null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc, context, 3,
          );
        }
        // When a truck is selected, fly the map to it
        if (state is GpsTruckMapLoaded && state.selected != null) {
          final t = state.selected!;
          _mapController.move(LatLng(t.lat, t.lng), 14.0);
        }
      },
      builder: (context, state) {
        if (state is GpsTruckMapInitial || state is GpsTruckMapLoading) {
          return const _LoadingOverlay();
        }
        if (state is GpsTruckMapError) {
          return _ErrorView(
            message: state.message,
            onRetry: () =>
                context.read<GpsTruckMapBloc>().add(const LoadTruckPositions()),
          );
        }
        if (state is GpsTruckMapLoaded) {
          return _MapBody(
            state:         state,
            mapController: _mapController,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Map body — the actual flutter_map + overlay UI
// ─────────────────────────────────────────────────────────────────────────────
class _MapBody extends StatelessWidget {
  final GpsTruckMapLoaded state;
  final MapController      mapController;

  const _MapBody({required this.state, required this.mapController});

  @override
  Widget build(BuildContext context) {
    final trucks = state.trucks;

    return Stack(
      children: [
        // ── Map ───────────────────────────────────────────────────────────
        FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: LatLng(3.0000, 101.3900), // Port Klang
            initialZoom:   10.0,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // OpenStreetMap tile layer — free, no API key needed
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.maleva.app',
              maxZoom: 19,
            ),
            // Truck markers
            MarkerLayer(
              markers: trucks
                  .map((truck) => _buildMarker(context, truck))
                  .toList(),
            ),
          ],
        ),

        // ── Top summary bar ────────────────────────────────────────────────
        Positioned(
          top: 12, left: 12, right: 12,
          child: _SummaryBar(trucks: trucks, isRefreshing: state.isRefreshing),
        ),

        // ── Refresh FAB ────────────────────────────────────────────────────
        Positioned(
          bottom: state.selected != null ? 260 : 16,
          right: 16,
          child: _RefreshFab(isRefreshing: state.isRefreshing),
        ),

        // ── Selected truck bottom sheet ────────────────────────────────────
        if (state.selected != null)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _TruckBottomSheet(truck: state.selected!),
          ),
      ],
    );
  }

  Marker _buildMarker(BuildContext context, TruckPosition truck) {
    final isSelected = state.selected?.unitId == truck.unitId;
    return Marker(
      point:  LatLng(truck.lat, truck.lng),
      width:  isSelected ? 52 : 44,
      height: isSelected ? 52 : 44,
      child: GestureDetector(
        onTap: () =>
            context.read<GpsTruckMapBloc>().add(SelectTruck(truck)),
        child: _TruckMarkerIcon(
          truck:      truck,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Marker icon — green = moving, amber = idle, grey = offline
// ─────────────────────────────────────────────────────────────────────────────
class _TruckMarkerIcon extends StatelessWidget {
  final TruckPosition truck;
  final bool          isSelected;

  const _TruckMarkerIcon({required this.truck, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    if (isSelected) {
      bg = const Color(0xFF1A2E5A);
    } else if (truck.isMoving) {
      bg = const Color(0xFF1D9E75); // teal-green = moving
    } else {
      bg = const Color(0xFFEF9F27); // amber = idle / parked
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.5),
            blurRadius: isSelected ? 12 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Icon(
        Icons.local_shipping_rounded,
        color: Colors.white,
        size:  isSelected ? 26 : 22,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Summary bar at the top
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  final List<TruckPosition> trucks;
  final bool                isRefreshing;

  const _SummaryBar({required this.trucks, required this.isRefreshing});

  @override
  Widget build(BuildContext context) {
    final total   = trucks.length;
    final moving  = trucks.where((t) => t.isMoving).length;
    final idle    = total - moving;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _statChip(label: 'Total',  value: '$total',  color: const Color(0xFF1A2E5A)),
          const SizedBox(width: 12),
          _statChip(label: 'Moving', value: '$moving', color: const Color(0xFF1D9E75)),
          const SizedBox(width: 12),
          _statChip(label: 'Idle',   value: '$idle',   color: const Color(0xFFEF9F27)),
          const Spacer(),
          if (isRefreshing)
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              'Live GPS',
              style: GoogleFonts.lato(
                fontSize: 11,
                color: const Color(0xFF1D9E75),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required Color  color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            )),
        Text(label,
            style: GoogleFonts.lato(
              fontSize: 10,
              color: Colors.grey[600],
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Refresh FAB
// ─────────────────────────────────────────────────────────────────────────────
class _RefreshFab extends StatelessWidget {
  final bool isRefreshing;
  const _RefreshFab({required this.isRefreshing});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      backgroundColor: Colors.white,
      elevation: 4,
      onPressed: isRefreshing
          ? null
          : () => context
          .read<GpsTruckMapBloc>()
          .add(const RefreshTruckPositions()),
      child: isRefreshing
          ? const SizedBox(
        width: 18, height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.refresh_rounded,
          color: Color(0xFF1A2E5A), size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bottom sheet that slides up when a truck is tapped
// ─────────────────────────────────────────────────────────────────────────────
class _TruckBottomSheet extends StatelessWidget {
  final TruckPosition truck;
  const _TruckBottomSheet({required this.truck});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Truck name + close
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2E5A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_shipping_rounded,
                      color: Color(0xFF1A2E5A), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    truck.truckName,
                    style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A2E5A),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.read<GpsTruckMapBloc>().add(const ClearSelection()),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status + speed chips
            Row(
              children: [
                _StatusChip(isMoving: truck.isMoving),
                const SizedBox(width: 10),
                _InfoChip(
                  icon:  Icons.speed_rounded,
                  label: '${truck.speedKmh.toStringAsFixed(0)} km/h',
                  color: const Color(0xFF185FA5),
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  icon:  Icons.access_time_rounded,
                  label: truck.lastUpdate,
                  color: Colors.grey[700]!,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Coordinates row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 16, color: Color(0xFF534AB7)),
                  const SizedBox(width: 6),
                  Text(
                    '${truck.lat.toStringAsFixed(5)}, '
                        '${truck.lng.toStringAsFixed(5)}',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: const Color(0xFF534AB7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isMoving;
  const _StatusChip({required this.isMoving});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isMoving
            ? const Color(0xFF1D9E75).withOpacity(0.12)
            : const Color(0xFFEF9F27).withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: isMoving
                  ? const Color(0xFF1D9E75)
                  : const Color(0xFFEF9F27),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isMoving ? 'Moving' : 'Idle',
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isMoving
                  ? const Color(0xFF0F6E56)
                  : const Color(0xFF854F0B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Loading overlay
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Connecting to GPS…',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Error view with retry button
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String   message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colour.AppColors.appBarColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}