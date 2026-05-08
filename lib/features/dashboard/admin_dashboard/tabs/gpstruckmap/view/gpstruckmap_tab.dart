import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/gpstruckmap_bloc.dart';
import '../bloc/gpstruckmap_event.dart';
import '../bloc/gpstruckmap_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Color palette — matching your existing app theme (colors.dart)
// ─────────────────────────────────────────────────────────────────────────────
const _kNavy   = Color(0xFF1A2E5A);
const _kGreen  = Color(0xFF1D9E75);
const _kAmber  = Color(0xFFEF9F27);
const _kGrey   = Color(0xFF9E9E9E);
const _kPurple = Color(0xFF534AB7);
const _kRed    = Color(0xFFE24B4A);

// ─────────────────────────────────────────────────────────────────────────────
//  Maleva HQ — Port Klang, Malaysia
// ─────────────────────────────────────────────────────────────────────────────
const _kPortKlang = LatLng(3.0042, 101.3903);
const _kInitZoom  = 10.5;

// ─────────────────────────────────────────────────────────────────────────────
//  Entry widget — plug this into admin_dashboard_ui.dart TabBarView
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
class _GpsTruckMapView extends StatefulWidget {
  const _GpsTruckMapView();
  @override
  State<_GpsTruckMapView> createState() => _GpsTruckMapViewState();
}

class _GpsTruckMapViewState extends State<_GpsTruckMapView> {
  final _mapCtrl = MapController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GpsTruckMapBloc, GpsTruckMapState>(
      listener: (ctx, state) {
        if (state is GpsTruckMapLoaded && state.selected != null) {
          // Fly to selected truck
          _mapCtrl.move(LatLng(state.selected!.lat, state.selected!.lng), 14.0);
        }
      },
      builder: (ctx, state) {
        if (state is GpsTruckMapInitial || state is GpsTruckMapLoading) {
          return const _LoadingView();
        }
        if (state is GpsTruckMapError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => ctx.read<GpsTruckMapBloc>().add(const LoadTruckPositions()),
          );
        }
        if (state is GpsTruckMapLoaded) {
          return _MapBody(state: state, mapCtrl: _mapCtrl);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Map body
// ─────────────────────────────────────────────────────────────────────────────
class _MapBody extends StatelessWidget {
  final GpsTruckMapLoaded state;
  final MapController     mapCtrl;
  const _MapBody({required this.state, required this.mapCtrl});

  @override
  Widget build(BuildContext context) {
    final sheetOpen = state.selected != null;

    return Stack(
      children: [
        // ── flutter_map ──────────────────────────────────────────────────
        FlutterMap(
          mapController: mapCtrl,
          options: const MapOptions(
            initialCenter: _kPortKlang,
            initialZoom:   _kInitZoom,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            // Free OpenStreetMap tiles
            TileLayer(
              urlTemplate:         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.maleva.app',
              maxZoom:              19,
            ),

            // ── Path polyline (drawn under markers) ──────────────────────
            if (state.hasPath)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points:       state.path
                        .map((p) => LatLng(p.lat, p.lng))
                        .toList(),
                    strokeWidth:  4.0,
                    color:        _kPurple.withOpacity(0.75),
                    // dotted appearance for path
                    pattern:      const StrokePattern.dotted(),
                  ),
                ],
              ),

            // ── Start / End markers when path is shown ───────────────────
            if (state.hasPath) ...[
              MarkerLayer(markers: [
                // START — green flag
                Marker(
                  point:     LatLng(state.path.first.lat, state.path.first.lng),
                  width:  28, height: 28,
                  child: _PathEndMarker(isStart: true),
                ),
                // END — red flag
                Marker(
                  point:     LatLng(state.path.last.lat, state.path.last.lng),
                  width:  28, height: 28,
                  child: _PathEndMarker(isStart: false),
                ),
              ]),
            ],

            // ── Live truck markers ───────────────────────────────────────
            MarkerLayer(
              markers: state.trucks.map((t) => _marker(context, t)).toList(),
            ),
          ],
        ),

        // ── Top summary bar ──────────────────────────────────────────────
        Positioned(
          top: 10, left: 10, right: 10,
          child: _SummaryBar(state: state),
        ),

        // ── Refresh FAB ──────────────────────────────────────────────────
        Positioned(
          right: 12,
          bottom: sheetOpen ? _sheetHeight + 12 : 20,
          child: _RefreshFab(isRefreshing: state.isRefreshing),
        ),

        // ── Fit-all FAB ──────────────────────────────────────────────────
        if (state.trucks.isNotEmpty)
          Positioned(
            right: 12,
            bottom: sheetOpen ? _sheetHeight + 64 : 72,
            child: _FitAllFab(trucks: state.trucks, mapCtrl: mapCtrl),
          ),

        // ── Path loading spinner ─────────────────────────────────────────
        if (state.isLoadingPath)
          const Positioned(
            left: 0, right: 0,
            bottom: 0, top: 0,
            child: _PathLoadingOverlay(),
          ),

        // ── Selected truck bottom sheet ──────────────────────────────────
        if (state.selected != null)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _TruckSheet(
              truck:      state.selected!,
              hasPath:    state.hasPath,
              pathPoints: state.path.length,
            ),
          ),
      ],
    );
  }

  // Approximate height of the bottom sheet for FAB offset
  double get _sheetHeight => 250.0;

  Marker _marker(BuildContext ctx, TruckPosition t) {
    final isSelected = state.selected?.unitId == t.unitId;
    return Marker(
      point:     LatLng(t.lat, t.lng),
      width:     90,
      height:    isSelected ? 68 : 58,
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => ctx.read<GpsTruckMapBloc>().add(SelectTruck(t)),
        child: _TruckMarker(truck: t, isSelected: isSelected),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Truck marker — name label above pin icon
// ─────────────────────────────────────────────────────────────────────────────
class _TruckMarker extends StatelessWidget {
  final TruckPosition truck;
  final bool          isSelected;
  const _TruckMarker({required this.truck, required this.isSelected});

  Color get _pinColor {
    if (isSelected)       return _kNavy;
    if (truck.isOffline)  return _kGrey;
    if (truck.isMoving)   return _kGreen;
    return _kAmber;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color:        isSelected ? _kNavy : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border:       Border.all(color: _pinColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4, offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            truck.truckName,
            style: GoogleFonts.lato(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : _kNavy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        // Icon pin
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:  isSelected ? 36 : 30,
          height: isSelected ? 36 : 30,
          decoration: BoxDecoration(
            color:  _pinColor,
            shape:  BoxShape.circle,
            border: Border.all(color: Colors.white, width: isSelected ? 2.5 : 2),
            boxShadow: [
              BoxShadow(
                color:      _pinColor.withOpacity(0.4),
                blurRadius: isSelected ? 12 : 5,
              ),
            ],
          ),
          child: Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size:  isSelected ? 19 : 15,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Path start/end markers
// ─────────────────────────────────────────────────────────────────────────────
class _PathEndMarker extends StatelessWidget {
  final bool isStart;
  const _PathEndMarker({required this.isStart});

  @override
  Widget build(BuildContext context) => Container(
    width: 26, height: 26,
    decoration: BoxDecoration(
      color:  isStart ? _kGreen : _kRed,
      shape:  BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(
          color: (isStart ? _kGreen : _kRed).withOpacity(0.5),
          blurRadius: 8,
        ),
      ],
    ),
    child: Icon(
      isStart ? Icons.play_arrow_rounded : Icons.stop_rounded,
      color: Colors.white, size: 14,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Summary bar
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  final GpsTruckMapLoaded state;
  const _SummaryBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _Stat(value: '${state.total}',   label: 'Total',   color: _kNavy),
          _vDivider(),
          _Stat(value: '${state.moving}',  label: 'Moving',  color: _kGreen),
          _vDivider(),
          _Stat(value: '${state.idle}',    label: 'Idle',    color: _kAmber),
          _vDivider(),
          _Stat(value: '${state.offline}', label: 'Offline', color: _kGrey),
          const Spacer(),
          state.isRefreshing
              ? const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen),
          )
              : Row(children: [
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text('Live',
                style: GoogleFonts.lato(
                  fontSize: 10, fontWeight: FontWeight.w700, color: _kGreen,
                )),
          ]),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
    height: 22, width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Colors.grey.shade200,
  );
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color  color;
  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value,
          style: GoogleFonts.lato(
            fontSize: 16, fontWeight: FontWeight.bold, color: color,
          )),
      Text(label,
          style: GoogleFonts.lato(fontSize: 9, color: Colors.grey[600])),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  FABs
// ─────────────────────────────────────────────────────────────────────────────
class _RefreshFab extends StatelessWidget {
  final bool isRefreshing;
  const _RefreshFab({required this.isRefreshing});

  @override
  Widget build(BuildContext context) => FloatingActionButton.small(
    heroTag:         'refresh',
    backgroundColor: Colors.white,
    elevation:       4,
    onPressed: isRefreshing
        ? null
        : () => context.read<GpsTruckMapBloc>().add(const RefreshTruckPositions()),
    child: isRefreshing
        ? const SizedBox(
      width: 16, height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: _kNavy),
    )
        : const Icon(Icons.refresh_rounded, color: _kNavy, size: 20),
  );
}

class _FitAllFab extends StatelessWidget {
  final List<TruckPosition> trucks;
  final MapController        mapCtrl;
  const _FitAllFab({required this.trucks, required this.mapCtrl});

  @override
  Widget build(BuildContext context) => FloatingActionButton.small(
    heroTag:         'fitall',
    backgroundColor: Colors.white,
    elevation:       4,
    onPressed: () {
      if (trucks.isEmpty) return;
      double minLat = trucks.first.lat, maxLat = trucks.first.lat;
      double minLng = trucks.first.lng, maxLng = trucks.first.lng;
      for (final t in trucks) {
        if (t.lat < minLat) minLat = t.lat;
        if (t.lat > maxLat) maxLat = t.lat;
        if (t.lng < minLng) minLng = t.lng;
        if (t.lng > maxLng) maxLng = t.lng;
      }
      mapCtrl.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat - 0.05, minLng - 0.05),
          LatLng(maxLat + 0.05, maxLng + 0.05),
        ),
        padding: const EdgeInsets.all(48),
      ));
    },
    child: const Icon(Icons.zoom_out_map_rounded, color: _kNavy, size: 20),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _TruckSheet extends StatelessWidget {
  final TruckPosition truck;
  final bool          hasPath;
  final int           pathPoints;
  const _TruckSheet({
    required this.truck,
    required this.hasPath,
    required this.pathPoints,
  });

  Color get _statusColor => truck.isOffline ? _kGrey : truck.isMoving ? _kGreen : _kAmber;
  String get _statusLabel => truck.isOffline ? 'Offline' : truck.isMoving ? 'Moving' : 'Idle / Parked';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 20, offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_shipping_rounded, color: _statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(truck.truckName,
                        style: GoogleFonts.lato(
                          fontSize: 16, fontWeight: FontWeight.bold, color: _kNavy,
                        )),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(_statusLabel,
                          style: GoogleFonts.lato(
                            fontSize: 12, color: _statusColor, fontWeight: FontWeight.w600,
                          )),
                    ]),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.read<GpsTruckMapBloc>().add(const ClearSelection()),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 18, color: Colors.black54),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Info chips ───────────────────────────────────────────────────
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _Chip(
                icon: Icons.speed_rounded,
                label: '${truck.speedKmh.toStringAsFixed(0)} km/h',
                bg: const Color(0xFFE6F1FB), fg: const Color(0xFF185FA5),
              ),
              _Chip(
                icon: Icons.access_time_rounded,
                label: truck.lastUpdate,
                bg: const Color(0xFFF1EFE8), fg: const Color(0xFF5F5E5A),
              ),
              _Chip(
                icon: Icons.location_on_rounded,
                label: '${truck.lat.toStringAsFixed(4)}, ${truck.lng.toStringAsFixed(4)}',
                bg: const Color(0xFFEEEDFE), fg: _kPurple,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Action buttons ───────────────────────────────────────────────
          Row(
            children: [
              // View Path button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasPath
                      ? null // already showing — grey it out
                      : () => context
                      .read<GpsTruckMapBloc>()
                      .add(LoadTruckPath(truck)),
                  icon:  Icon(
                    hasPath
                        ? Icons.check_circle_rounded
                        : Icons.route_rounded,
                    size: 16,
                  ),
                  label: Text(
                    hasPath
                        ? 'Path shown ($pathPoints pts)'
                        : "Today's path",
                    style: GoogleFonts.lato(
                      fontSize: 13, fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasPath ? Colors.grey[200] : _kPurple,
                    foregroundColor: hasPath ? Colors.grey[600] : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Focus on truck button
              ElevatedButton(
                onPressed: () => context
                    .read<GpsTruckMapBloc>()
                    .add(SelectTruck(truck)), // re-fires map fly
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.my_location_rounded, size: 18),
              ),
            ],
          ),

          // Path info row when path is loaded
          if (hasPath) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _kPurple.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kPurple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: _kPurple),
                  const SizedBox(width: 6),
                  Text(
                    'Showing today\'s route  ·  $pathPoints GPS points',
                    style: GoogleFonts.lato(
                      fontSize: 11, color: _kPurple, fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    bg, fg;
  const _Chip({required this.icon, required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.lato(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg,
            )),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Path loading overlay
// ─────────────────────────────────────────────────────────────────────────────
class _PathLoadingOverlay extends StatelessWidget {
  const _PathLoadingOverlay();

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _kPurple),
            const SizedBox(height: 12),
            Text(
              'Loading today\'s route…',
              style: GoogleFonts.lato(fontSize: 13, color: _kNavy),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Loading / Error
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: _kNavy),
        SizedBox(height: 14),
        Text('Connecting to GPS…',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
              size: 52, color: Colors.grey[400]),
          const SizedBox(height: 14),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon:  const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kNavy, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  );
}