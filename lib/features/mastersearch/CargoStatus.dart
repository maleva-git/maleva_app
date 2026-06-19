import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CargoStatus extends StatefulWidget {
  final int Searchby;
  final int SearchId;

  const CargoStatus({super.key, required this.Searchby, required this.SearchId});

  @override
  _CargoStatusstate createState() => _CargoStatusstate();
}

class _CargoStatusstate extends State<CargoStatus> {
  bool progress = false;
  final txtSearch = TextEditingController();

  final List<String> CargoStatusList = <String>[
    "AT AIRPORT",
    "NOT ARRIVED",
    "WESTPORT",
    "NORTHPORT",
    "SOUTHPORT",
    "PKG OFFICE",
    "SEREMBAN OFFICE",
    "PTP OFFICE",
    "PTP CABIN",
    "PGU CABIN",
    "DELIVERED",
  ];
  List<String> filtersearchlist = <String>[];

  @override
  void initState() {
    startup();
    super.initState();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  // ─── Logic (Untouched) ───────────────────────────────────────────────────

  Future startup() async {
    filtersearchlist = CargoStatusList;
    if (mounted) {
      setState(() {
        progress = true;
      });
    }
  }

  void search(String value) {
    setState(() {
      if (value.isEmpty) {
        filtersearchlist = CargoStatusList;
      } else {
        filtersearchlist = CargoStatusList.where(
                (item) => item.toLowerCase().contains(value.toLowerCase())).toList();
      }
    });
  }

  void _onItemTapped(String item) {
    if (widget.Searchby == 1) {
      objfun.SelectedCargoName = item;
      Navigator.of(context, rootNavigator: true).pop(context);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isTablet = objfun.MalevaScreen != 1;
    return isTablet ? _buildTabletLayout() : _buildPhoneLayout();
  }

  Widget _buildPhoneLayout() =>
      Scaffold(appBar: _buildAppBar(), body: _buildBody());

  Widget _buildTabletLayout() => Scaffold(
    appBar: _buildAppBar(),
    backgroundColor: Colors.grey.shade100, // Softer background for tablet
    body: Padding(
      padding: const EdgeInsets.only(
          left: 100, right: 100, top: 50, bottom: 40),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildBody(),
        ),
      ),
    ),
  );

  // ─── Body States ─────────────────────────────────────────────────────────

  Widget _buildBody() {
    // Loading State
    if (!progress) {
      return const Center(
        child: SpinKitFoldingCube(color: colour.spinKitColor, size: 35.0),
      );
    }

    // Loaded State
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildSearchField(),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
        Expanded(child: _buildListOrEmpty()),
      ],
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: colour.commonColor,
      centerTitle: objfun.MalevaScreen != 1,
      elevation: 0,
      title: Text(
        'Cargo Status',
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: colour.topAppBarColor,
            fontWeight: FontWeight.bold,
            fontSize: objfun.FontLarge,
            letterSpacing: 0.5,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: colour.topAppBarColor, size: 24.0),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: txtSearch,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.characters,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: colour.commonColor,
            fontWeight: FontWeight.w600,
            fontSize: objfun.FontLow,
            letterSpacing: 0.3,
          ),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: colour.commonColor, width: 2.0),
          ),
          hintText: 'Search Cargo...',
          hintStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              letterSpacing: 1,
              color: Colors.grey.shade500,
              fontSize: objfun.FontLow,
            ),
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: txtSearch.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.cancel, color: Colors.grey),
            onPressed: () {
              txtSearch.clear();
              search('');
            },
          )
              : null,
        ),
        onChanged: search,
        onSubmitted: search,
      ),
    );
  }

  Widget _buildListOrEmpty() {
    if (filtersearchlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              txtSearch.text.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              txtSearch.text.isNotEmpty ? 'No match found' : 'No Cargo Records',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontLow,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: filtersearchlist.length,
      itemBuilder: (context, index) {
        final item = filtersearchlist[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          elevation: 2.0,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colour.commonColor.withOpacity(0.15), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _onItemTapped(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colour.commonColor.withOpacity(0.1),
                  child: const Icon(Icons.inventory_2, color: colour.commonColor), // Cargo box icon
                ),
                title: Text(
                  item.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.w600,
                      fontSize: objfun.FontCardText,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ),
            ),
          ),
        );
      },
    );
  }
}