import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddressList extends StatefulWidget {
  final int Searchby;
  final int SearchId;

  const AddressList(
      {super.key, required this.Searchby, required this.SearchId});

  @override
  _AddressListstate createState() => _AddressListstate();
}

class _AddressListstate extends State<AddressList> {
  // null=loading  true=loaded  false=error
  bool? _loadState;
  String _errorMsg = '';

  final txtSearch = TextEditingController();
  List<String> _masterList = [];
  List<String> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _startup();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  // ─── Fetch (Untouched) ───────────────────────────────────────────────────

  Future<void> _startup() async {
    if (mounted) setState(() { _loadState = null; _errorMsg = ''; });

    try {
      final response = await ApiClient.postRequest(
        '${ApiConstants.apiSelectAddressList}${AppGlobals.Comid}',
        null,
      );

      if (!mounted) return;

      List<String> loaded = [];
      if (response is List) {
        loaded = response.map((e) => e.toString()).toList();
      }

      AppGlobals.AddressList = loaded;

      setState(() {
        _masterList = loaded;
        _filteredList = List<String>.from(loaded);
        _loadState = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _loadState = false;
      });
    }
  }

  // ─── Search (Untouched) ──────────────────────────────────────────────────

  void _search(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _filteredList = List<String>.from(_masterList);
      } else {
        final q = value.toLowerCase();
        _filteredList = _masterList
            .where((item) => item.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  void _onItemTapped(String selected) {
    Navigator.of(context, rootNavigator: true).pop(selected);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isTablet = AppGlobals.MalevaScreen != 1;
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

  // ─── Body states ─────────────────────────────────────────────────────────

  Widget _buildBody() {
    // Loading
    if (_loadState == null) {
      return const Center(
        child: SpinKitFoldingCube(color: colour.spinKitColor, size: 35.0),
      );
    }

    // Error
    if (_loadState == false) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colour.commonColorred.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off, color: colour.commonColorred, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load addresses',
              style: GoogleFonts.lato(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: AppGlobals.FontLow,
              ),
            ),
            if (_errorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
                child: Text(
                  _errorMsg,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade600,
                    fontSize: AppGlobals.FontCardText,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: colour.commonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text('Retry',
                  style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _startup,
            ),
          ],
        ),
      );
    }

    // Loaded
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
      centerTitle: AppGlobals.MalevaScreen != 1,
      elevation: 0,
      title: Text(
        'Address List',
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: colour.topAppBarColor,
            fontWeight: FontWeight.bold,
            fontSize: AppGlobals.FontLarge,
            letterSpacing: 0.5,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: colour.topAppBarColor, size: 24.0), // Modern back icon
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
            fontSize: AppGlobals.FontLow,
            letterSpacing: 0.3,
          ),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100, // Nice soft background
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: colour.commonColor, width: 2.0),
          ),
          hintText: 'Search Address...',
          hintStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              letterSpacing: 1,
              color: Colors.grey.shade500,
              fontSize: AppGlobals.FontLow,
            ),
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: txtSearch.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.cancel, color: Colors.grey),
            onPressed: () {
              txtSearch.clear();
              _search('');
            },
          )
              : null,
        ),
        onChanged: _search,
        onSubmitted: _search,
      ),
    );
  }

  Widget _buildListOrEmpty() {
    if (_filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              txtSearch.text.isNotEmpty ? Icons.search_off : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              txtSearch.text.isNotEmpty ? 'No match found' : 'No Records Available',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: AppGlobals.FontLow,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final item = _filteredList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          elevation: 2.0, // Reduced from 10 for a cleaner look
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colour.commonColor.withOpacity(0.15), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12), // Match card radius
            onTap: () {
              if (widget.Searchby == 1) _onItemTapped(item);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // Allow 2 lines just in case address is long
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.w600,
                      fontSize: AppGlobals.FontCardText,
                      letterSpacing: 0.3,
                      height: 1.4,
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