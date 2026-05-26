import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
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

  final txtSearch    = TextEditingController();
  List<String> _masterList   = [];
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

  // ─── Fetch ───────────────────────────────────────────────────────────────

  Future<void> _startup() async {
    if (mounted) setState(() { _loadState = null; _errorMsg = ''; });

    try {
      // Call the API via ApiClient (POST with auth headers, same as every
      // other screen in the app).
      final response = await ApiClient.postRequest(
        '${objfun.apiSelectAddressList}${objfun.Comid}',
        null, // no request body — this endpoint takes no body
      );

      if (!mounted) return;

      List<String> loaded = [];
      if (response is List) {
        loaded = response.map((e) => e.toString()).toList();
      }

      // Also update the global so the rest of the app sees the fresh data
      objfun.AddressList = loaded;

      setState(() {
        _masterList   = loaded;
        _filteredList = List<String>.from(loaded);
        _loadState    = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg  = e.toString();
        _loadState = false;
      });
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────

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
    objfun.SelectAddressList = selected;
    Navigator.of(context, rootNavigator: true).pop(selected);
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
    body: Padding(
      padding: const EdgeInsets.only(
          left: 100, right: 100, top: 50, bottom: 40),
      child: Card(elevation: 12, child: _buildBody()),
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
            const Icon(Icons.wifi_off, color: colour.commonColorred, size: 48),
            const SizedBox(height: 12),
            Text(
              'Failed to load addresses',
              style: GoogleFonts.lato(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLow,
              ),
            ),
            if (_errorMsg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8),
                child: Text(
                  _errorMsg,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: Colors.grey,
                    fontSize: objfun.FontCardText,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: colour.commonColor),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text('Retry',
                  style: GoogleFonts.lato(color: Colors.white)),
              onPressed: _startup,
            ),
          ],
        ),
      );
    }

    // Loaded
    final double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        const SizedBox(height: 5),
        _buildSearchField(height * 0.06),
        const SizedBox(height: 5),
        const Divider(color: colour.commonColor, thickness: 1, height: 1),
        const SizedBox(height: 5),
        Expanded(child: _buildListOrEmpty()),
      ],
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: colour.commonColor,
      centerTitle: objfun.MalevaScreen != 1,
      title: Text(
        'Address',
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: colour.topAppBarColor,
            fontWeight: FontWeight.bold,
            fontSize: objfun.FontLarge,
            letterSpacing: 0.3,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,
            color: colour.topAppBarColor, size: 35.0),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchField(double fieldHeight) {
    return Container(
      height: fieldHeight,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: txtSearch,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.characters,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: colour.commonColor,
            fontWeight: FontWeight.bold,
            fontSize: objfun.FontLow,
            letterSpacing: 0.3,
          ),
        ),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: colour.commonColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: colour.commonColorred),
          ),
          hintText: 'Search Address',
          hintStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: objfun.FontLow,
            ),
          ),
          suffixIcon: txtSearch.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: colour.commonColorred),
            onPressed: () {
              txtSearch.clear();
              _search('');
            },
          )
              : const Icon(Icons.search, color: colour.commonColor),
        ),
        onChanged: _search,
        onSubmitted: _search,
      ),
    );
  }

  Widget _buildListOrEmpty() {
    if (_filteredList.isEmpty) {
      return Center(
        child: Text(
          txtSearch.text.isNotEmpty ? 'No match found' : 'No Record',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _filteredList.length,
      itemBuilder: (context, index) {
        final item = _filteredList[index];
        return InkWell(
          onTap: () {
            if (widget.Searchby == 1) _onItemTapped(item);
          },
          child: SizedBox(
            height: 55,
            child: Card(
              margin: const EdgeInsets.only(
                  right: 5.0, left: 5.0, top: 1, bottom: 1),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: colour.commonColor, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: colour.commonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontCardText,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}