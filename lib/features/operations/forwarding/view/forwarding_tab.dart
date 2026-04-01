import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Employee.dart';
import '../bloc/forwarding_bloc.dart';
import '../bloc/forwarding_event.dart';
import '../bloc/forwarding_state.dart';


// ─── Design Tokens ────────────────────────────────────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class FWUpdate extends StatelessWidget {
  const FWUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FWUpdateBloc()..add(FWUpdateStarted()),
      child: const FWUpdatePage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class FWUpdatePage extends StatefulWidget {
  const FWUpdatePage();

  @override
  State<FWUpdatePage> createState() => FWUpdatePageState();
}

class FWUpdatePageState extends State<FWUpdatePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pickers = [ImagePicker(), ImagePicker(), ImagePicker()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<FWUpdateBloc>()
            .add(FWUpdateTabChanged(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(
      BuildContext context, ImageSource source, int type, String smkText) async {
    if (smkText.isEmpty) {
      objfun.toastMsg('Enter SMK No $type', '', context);
      return;
    }
    final s = context.read<FWUpdateBloc>().state;
    if (s is! FWUpdateLoaded) return;

    final picker = _pickers[type - 1];
    final file = await picker.pickImage(source: source);
    if (file == null) return;

    final url = await objfun.upload(
        File(file.path), objfun.apiPostimage, s.saleOrderId, 'SalesOrder', smkText);
    context.read<FWUpdateBloc>().add(
        FWUpdateImagePicked(type: type, imageUrl: url));
  }

  @override
  Widget build(BuildContext context) {
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<FWUpdateBloc, FWUpdateState>(
      listener: (context, state) async {
        if (state is FWUpdateSaveSuccess) {
          await objfun.ConfirmationOK('Updated Successfully', context);
        }
        if (state is FWUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: const Color(0xFFB33040),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        if (state is FWUpdateShowImagePreview) {
          _showImagePreview(context, state.imageUrl);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: kPageBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<FWUpdateBloc, FWUpdateState>(
            builder: (context, state) {
              if (state is FWUpdateInitial || state is FWUpdateLoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is FWUpdateLoaded) {
                // Sync tab controller
                if (_tabController.index != state.currentTab) {
                  _tabController.animateTo(state.currentTab);
                }
                return GestureDetector(
                  onTap: () => context
                      .read<FWUpdateBloc>()
                      .add(FWUpdateOverlayDismissed()),
                  child: _FWUpdateBody(
                    state: state,
                    tabController: _tabController,
                    onPickImage: (source, type, smk) =>
                        _pickImage(context, source, type, smk),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          bottomNavigationBar: BlocBuilder<FWUpdateBloc, FWUpdateState>(
            builder: (context, state) {
              final idx = state is FWUpdateLoaded ? state.currentTab : 0;
              return _FWBottomNav(
                currentIndex: idx,
                onTap: (i) {
                  _tabController.animateTo(i);
                  context.read<FWUpdateBloc>().add(FWUpdateTabChanged(i));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String userName) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 62,
      flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FW Entry Update',
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(userName,
              style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: _AppBarButton(
            label: 'Update',
            onPressed: () {
              final state = context.read<FWUpdateBloc>().state;
              if (state is FWUpdateLoaded) {
                final smk1 = state.tab1.smkText.isNotEmpty;
                final smk2 = state.tab2.smkText.isNotEmpty;
                final smk3 = state.tab3.smkText.isNotEmpty;

                if (!smk1 && !smk2 && !smk3) {
                  objfun.toastMsg('Enter Entry SMK No', '', context);
                  return;
                }
                if ((smk1 && smk2) || (smk1 && smk3) || (smk2 && smk3)) {
                  objfun.toastMsg('Enter Proper Entry Details', '', context);
                  return;
                }
                objfun
                    .ConfirmationMsgYesNo(context, 'Are you sure to Update ?')
                    .then((confirmed) {
                  if (confirmed == true) {
                    context
                        .read<FWUpdateBloc>()
                        .add(FWUpdateSaveRequested());
                  }
                });
              }
            },
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (_, __) =>
                const CircularProgressIndicator(color: kHeaderGradEnd),
              ),
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: kHeaderGradStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _FWUpdateBody extends StatelessWidget {
  final FWUpdateLoaded state;
  final TabController tabController;
  final Future<void> Function(ImageSource, int, String) onPickImage;

  const _FWUpdateBody({
    required this.state,
    required this.tabController,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        // Tablet: add horizontal padding so content is not edge-to-edge
        final hPad = isTablet ? constraints.maxWidth * 0.06 : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _FWTabContent(
                type: 1,
                tab: state.tab1,
                saleOrderId: state.saleOrderId,
                isTablet: isTablet,
                onPickImage: onPickImage,
              ),
              _FWTabContent(
                type: 2,
                tab: state.tab2,
                saleOrderId: state.saleOrderId,
                isTablet: isTablet,
                onPickImage: onPickImage,
              ),
              _FWTabContent(
                type: 3,
                tab: state.tab3,
                saleOrderId: state.saleOrderId,
                isTablet: isTablet,
                onPickImage: onPickImage,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Single Tab Content ───────────────────────────────────────────────────────
class _FWTabContent extends StatefulWidget {
  final int type;
  final FWTabData tab;
  final int saleOrderId;
  final bool isTablet;
  final Future<void> Function(ImageSource, int, String) onPickImage;

  const _FWTabContent({
    required this.type,
    required this.tab,
    required this.saleOrderId,
    required this.isTablet,
    required this.onPickImage,
  });

  @override
  State<_FWTabContent> createState() => _FWTabContentState();
}

class _FWTabContentState extends State<_FWTabContent> {
  late TextEditingController _smkController;
  late TextEditingController _exRefController;

  @override
  void initState() {
    super.initState();
    _smkController = TextEditingController(text: widget.tab.smkText);
    _exRefController = TextEditingController(text: widget.tab.exRef);
  }

  @override
  void didUpdateWidget(_FWTabContent old) {
    super.didUpdateWidget(old);
    if (widget.tab.smkText != _smkController.text) {
      _smkController.text = widget.tab.smkText;
      _smkController.selection =
          TextSelection.collapsed(offset: widget.tab.smkText.length);
    }
    if (widget.tab.exRef != _exRefController.text) {
      _exRefController.text = widget.tab.exRef;
      _exRefController.selection =
          TextSelection.collapsed(offset: widget.tab.exRef.length);
    }
  }

  @override
  void dispose() {
    _smkController.dispose();
    _exRefController.dispose();
    super.dispose();
  }

  void _emit(FWUpdateEvent e) => context.read<FWUpdateBloc>().add(e);

  @override
  Widget build(BuildContext context) {
    final t = widget.type;
    final tab = widget.tab;
    final isTablet = widget.isTablet;

    return ListView(
      padding: EdgeInsets.fromLTRB(14, 16, 14, isTablet ? 24 : 16),
      children: [
        // ── SMK Field + autocomplete ─────────────────────────────────
        _FieldLabel('SMK No $t', isTablet),
        const SizedBox(height: 6),
        _SmkField(
          type: t,
          controller: _smkController,
          suggestions: tab.suggestions,
          isTablet: isTablet,
          onChanged: (v) => _emit(FWUpdateSmkTextChanged(type: t, text: v)),
          onSuggestionTap: (id, smk) => _emit(FWUpdateSmkSuggestionSelected(
              type: t, saleOrderId: id, smkText: smk)),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // ── Seal By ──────────────────────────────────────────────────
        _FieldLabel('Seal By', isTablet),
        const SizedBox(height: 6),
        _EmployeeSearchField(
          hint: 'Seal By',
          value: tab.sealEmpName,
          isTablet: isTablet,
          onSearch: () async {
            await OnlineApi.SelectEmployee(context, '', 'Operation');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Employee(Searchby: 1, SearchId: 0)),
            ).then((_) {
              final sel = objfun.SelectEmployeeList;
              if (sel.Id != 0) {
                _emit(FWUpdateSealEmpChanged(
                    type: t, empId: sel.Id, empName: sel.AccountName));
                objfun.SelectEmployeeList = EmployeeModel.Empty();
              }
            });
          },
          onClear: () => _emit(FWUpdateSealEmpCleared(t)),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // ── EX Ref ───────────────────────────────────────────────────
        _FieldLabel('EX Ref $t', isTablet),
        const SizedBox(height: 6),
        _FWTextField(
          controller: _exRefController,
          hint: 'EX.Ref $t',
          isTablet: isTablet,
          onChanged: (v) => _emit(FWUpdateExRefChanged(type: t, value: v)),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        // ── Break Seal By ────────────────────────────────────────────
        _FieldLabel('Break Seal By', isTablet),
        const SizedBox(height: 6),
        _EmployeeSearchField(
          hint: 'B.Seal By',
          value: tab.breakEmpName,
          isTablet: isTablet,
          onSearch: () async {
            await OnlineApi.SelectEmployee(context, '', 'Operation');
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const Employee(Searchby: 1, SearchId: 0)),
            ).then((_) {
              final sel = objfun.SelectEmployeeList;
              if (sel.Id != 0) {
                _emit(FWUpdateBreakEmpChanged(
                    type: t, empId: sel.Id, empName: sel.AccountName));
                objfun.SelectEmployeeList = EmployeeModel.Empty();
              }
            });
          },
          onClear: () => _emit(FWUpdateBreakEmpCleared(t)),
        ),
        SizedBox(height: isTablet ? 20 : 14),

        // ── Image upload section ─────────────────────────────────────
        _ImageUploadSection(
          type: t,
          tab: tab,
          saleOrderId: widget.saleOrderId,
          isTablet: isTablet,
          onPickImage: widget.onPickImage,
        ),
      ],
    );
  }
}

// ─── SMK Field with inline autocomplete dropdown ──────────────────────────────
class _SmkField extends StatelessWidget {
  final int type;
  final TextEditingController controller;
  final List<dynamic> suggestions;
  final bool isTablet;
  final void Function(String) onChanged;
  final void Function(int id, String smk) onSuggestionTap;

  const _SmkField({
    required this.type,
    required this.controller,
    required this.suggestions,
    required this.isTablet,
    required this.onChanged,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.lato(
            color: kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'SMK No $type',
            hintStyle: GoogleFonts.lato(
                color: kTextMuted,
                fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
            filled: true,
            fillColor: kDetailBg,
            prefixIcon:
            const Icon(Icons.tag_rounded, color: kHeaderGradEnd, size: 20),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kCardBorder, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: kHeaderGradEnd, width: 1.5),
            ),
          ),
        ),
        // Inline dropdown
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kCardBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: kHeaderGradStart.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: kDetailBg),
              itemBuilder: (ctx, i) {
                final item = suggestions[i];
                final smkKey = type == 1
                    ? 'ForwardingSMKNo'
                    : type == 2
                    ? 'ForwardingSMKNo2'
                    : 'ForwardingSMKNo3';
                final smkVal = item[smkKey].toString();
                return InkWell(
                  onTap: () => onSuggestionTap(item['Id'], smkVal),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined,
                            size: 16, color: kHeaderGradEnd),
                        const SizedBox(width: 10),
                        Text(smkVal,
                            style: GoogleFonts.lato(
                                color: kTextDark,
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet
                                    ? objfun.FontLow + 1
                                    : objfun.FontLow)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─── Image Upload Section ─────────────────────────────────────────────────────
class _ImageUploadSection extends StatelessWidget {
  final int type;
  final FWTabData tab;
  final int saleOrderId;
  final bool isTablet;
  final Future<void> Function(ImageSource, int, String) onPickImage;

  const _ImageUploadSection({
    required this.type,
    required this.tab,
    required this.saleOrderId,
    required this.isTablet,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final gridCols = isTablet ? 4 : 3;
    final imgGridHeight = isTablet ? 320.0 : 260.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Upload toggle row ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: kDetailBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kCardBorder, width: 0.5),
          ),
          child: Row(
            children: [
              // Animated checkbox
              InkWell(
                onTap: () => context.read<FWUpdateBloc>().add(
                    FWUpdateImageUploadToggled(
                        type: type, value: !tab.imageUploadEnabled)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isTablet ? 22 : 18,
                  height: isTablet ? 22 : 18,
                  decoration: BoxDecoration(
                    gradient:
                    tab.imageUploadEnabled ? kGradient : null,
                    border: tab.imageUploadEnabled
                        ? null
                        : Border.all(color: kCardBorder, width: 1.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: tab.imageUploadEnabled
                      ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Upload Image',
                style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
                ),
              ),
              const Spacer(),
              // Gallery
              _ImagePickBtn(
                icon: Icons.photo_outlined,
                enabled: tab.imageUploadEnabled,
                isTablet: isTablet,
                onTap: () => onPickImage(ImageSource.gallery, type, tab.smkText),
              ),
              const SizedBox(width: 4),
              // Camera
              _ImagePickBtn(
                icon: Icons.camera_alt_outlined,
                enabled: tab.imageUploadEnabled,
                isTablet: isTablet,
                onTap: () => onPickImage(ImageSource.camera, type, tab.smkText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Image grid ────────────────────────────────────────────────
        Container(
          height: imgGridHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kCardBorder, width: 0.5),
          ),
          child: tab.images.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined,
                    size: isTablet ? 48 : 36,
                    color: kTextMuted),
                const SizedBox(height: 8),
                Text('No images uploaded',
                    style: GoogleFonts.lato(
                        color: kTextMuted, fontSize: 13)),
              ],
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCols,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: tab.images.length,
              itemBuilder: (ctx, index) {
                final smkText = type == 1
                    ? tab.smkText
                    : tab.smkText;
                final imageUrl =
                    '${objfun.imagepath}SalesOrder/$saleOrderId/$smkText/${tab.images[index]}';

                return InkWell(
                  onLongPress: () async {
                    final ok = await objfun.ConfirmationMsgYesNo(
                        ctx, 'Are you sure to Delete ?');
                    if (ok == true) {
                      context.read<FWUpdateBloc>().add(
                          FWUpdateImageDeleted(
                              type: type, index: index));
                    }
                  },
                  onTap: () => objfun.launchInBrowser(imageUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: kDetailBg,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: kHeaderGradEnd,
                                strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: kDetailBg,
                        child: const Icon(Icons.file_copy_outlined,
                            color: kHeaderGradEnd),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Image pick icon button ───────────────────────────────────────────────────
class _ImagePickBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isTablet;
  final VoidCallback onTap;

  const _ImagePickBtn({
    required this.icon,
    required this.enabled,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? kHeaderGradStart.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: isTablet ? 28 : 24,
          color: enabled ? kHeaderGradStart : kTextMuted,
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _FWBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _FWBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kCardBorder, width: 0.5)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        selectedItemColor: kHeaderGradStart,
        unselectedItemColor: kTextMuted,
        selectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w700, fontSize: objfun.FontLow),
        unselectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w500, fontSize: objfun.FontCardText),
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'FW 1'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'FW 2'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'FW 3'),
        ],
      ),
    );
  }
}

// ─── Shared Reusable Widgets ──────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const _FieldLabel(this.text, this.isTablet);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lato(
        color: kTextMid,
        fontWeight: FontWeight.w600,
        fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
      ),
    );
  }
}

class _EmployeeSearchField extends StatelessWidget {
  final String hint;
  final String value;
  final bool isTablet;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _EmployeeSearchField({
    required this.hint,
    required this.value,
    required this.isTablet,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: value.isEmpty ? onSearch : onClear,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: GoogleFonts.lato(
                  color: value.isEmpty ? kTextMuted : kTextDark,
                  fontWeight:
                  value.isEmpty ? FontWeight.w500 : FontWeight.w600,
                  fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              value.isNotEmpty ? Icons.close_rounded : Icons.search_rounded,
              size: 20,
              color: kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _FWTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isTablet;
  final void Function(String) onChanged;

  const _FWTextField({
    required this.controller,
    required this.hint,
    required this.isTablet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      style: GoogleFonts.lato(
        color: kTextDark,
        fontWeight: FontWeight.w600,
        fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(
            color: kTextMuted,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
        filled: true,
        fillColor: kDetailBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kCardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kHeaderGradEnd, width: 1.5),
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _AppBarButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(label,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: objfun.FontMedium)),
          ),
        ),
      ),
    );
  }
}