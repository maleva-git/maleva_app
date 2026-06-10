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
import '../../../../core/di/injection.dart';
import '../../../../core/theme/palette.dart';
import '../../../mastersearch/Employee.dart';
import '../bloc/forwarding_bloc.dart';
import '../bloc/forwarding_event.dart';
import '../bloc/forwarding_state.dart';


const kGradient = LinearGradient(
  colors: [Palette.blue700, Palette.blue400],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;


// =========================================================================
// UI: FWUpdate Page & Widgets
// =========================================================================

class FWUpdate extends StatelessWidget {
  const FWUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FWUpdateBloc>()..add(FWUpdateStarted()),
      child: const FWUpdatePage(),
    );
  }
}

class FWUpdatePage extends StatefulWidget {
  const FWUpdatePage();

  @override
  State<FWUpdatePage> createState() => FWUpdatePageState();
}

class FWUpdatePageState extends State<FWUpdatePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pickers = [ImagePicker(), ImagePicker(), ImagePicker()];

  @override
  void initState() {
    super.initState();
    // Fixed: Initializing the Global JobNoList
    OnlineApi.GetJobNoForwarding(context, 3);

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<FWUpdateBloc>().add(FWUpdateTabChanged(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source, int type, String smkText) async {
    if (smkText.isEmpty) {
      objfun.toastMsg('Enter SMK No $type', '', context);
      return;
    }
    final s = context.read<FWUpdateBloc>().state;
    if (s is! FWUpdateLoaded) return;

    final picker = _pickers[type - 1];
    final file = await picker.pickImage(source: source);
    if (file == null) return;

    final url = await objfun.upload(File(file.path), objfun.apiPostimage, s.saleOrderId, 'SalesOrder', smkText);
    if (url != null && url.isNotEmpty) {
      context.read<FWUpdateBloc>().add(FWUpdateImagePicked(type: type, imageUrl: url));
    }
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
              content: Text(state.message, style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: const Color(0xFFB33040),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        if (state is FWUpdateShowImagePreview) {
          _showImagePreview(context, state.imageUrl);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          context.read<FWUpdateBloc>().add(FWUpdateOverlayDismissed());
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Palette.grey100,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<FWUpdateBloc, FWUpdateState>(
            builder: (context, state) {
              if (state is FWUpdateInitial || state is FWUpdateLoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: Palette.blue400, size: 35),
                );
              }
              if (state is FWUpdateLoaded) {
                if (_tabController.index != state.currentTab) {
                  _tabController.animateTo(state.currentTab);
                }
                // Fixed: Removed GestureDetector wrapper that was killing the overlay focus
                return _FWUpdateBody(
                  state: state,
                  tabController: _tabController,
                  onPickImage: (source, type, smk) => _pickImage(context, source, type, smk),
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
                  context.read<FWUpdateBloc>().add(FWUpdateOverlayDismissed());
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
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () {
          context.read<FWUpdateBloc>().add(FWUpdateOverlayDismissed());
          Navigator.pop(context);
        },
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FW Entry Update',
              style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(userName,
              style: GoogleFonts.lato(color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: _AppBarButton(
            label: 'Update',
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.read<FWUpdateBloc>().add(FWUpdateOverlayDismissed());

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
                objfun.ConfirmationMsgYesNo(context, 'Are you sure to Update ?').then((confirmed) {
                  if (confirmed == true) {
                    context.read<FWUpdateBloc>().add(FWUpdateSaveRequested());
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
                placeholder: (_, __) => const CircularProgressIndicator(color: Palette.blue400),
              ),
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Palette.blue700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FWUpdateBody extends StatelessWidget {
  final FWUpdateLoaded state;
  final TabController tabController;
  final Future<void> Function(ImageSource, int, String) onPickImage;

  const _FWUpdateBody({required this.state, required this.tabController, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad = isTablet ? constraints.maxWidth * 0.06 : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _FWTabContent(type: 1, tab: state.tab1, saleOrderId: state.saleOrderId, isTablet: isTablet, onPickImage: onPickImage),
              _FWTabContent(type: 2, tab: state.tab2, saleOrderId: state.saleOrderId, isTablet: isTablet, onPickImage: onPickImage),
              _FWTabContent(type: 3, tab: state.tab3, saleOrderId: state.saleOrderId, isTablet: isTablet, onPickImage: onPickImage),
            ],
          ),
        );
      },
    );
  }
}

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
  late TextEditingController _enRefController;
  late TextEditingController _exRefController;

  @override
  void initState() {
    super.initState();
    _smkController = TextEditingController(text: widget.tab.smkText);
    _enRefController = TextEditingController(text: widget.tab.enRef);
    _exRefController = TextEditingController(text: widget.tab.exRef);
  }

  @override
  void didUpdateWidget(_FWTabContent old) {
    super.didUpdateWidget(old);
    // Safe text updating without killing cursor
    if (widget.tab.smkText != _smkController.text) {
      _smkController.value = TextEditingValue(
        text: widget.tab.smkText,
        selection: TextSelection.collapsed(offset: widget.tab.smkText.length),
      );
    }
    if (widget.tab.enRef != _enRefController.text) {
      _enRefController.value = TextEditingValue(
        text: widget.tab.enRef,
        selection: TextSelection.collapsed(offset: widget.tab.enRef.length),
      );
    }
    if (widget.tab.exRef != _exRefController.text) {
      _exRefController.value = TextEditingValue(
        text: widget.tab.exRef,
        selection: TextSelection.collapsed(offset: widget.tab.exRef.length),
      );
    }
  }

  @override
  void dispose() {
    _smkController.dispose();
    _enRefController.dispose();
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
        _FieldLabel('SMK No $t', isTablet),
        const SizedBox(height: 6),
        _SmkField(
          type: t,
          controller: _smkController,
          suggestions: tab.suggestions,
          isTablet: isTablet,
          onChanged: (v) => _emit(FWUpdateSmkTextChanged(type: t, text: v)),
          onSuggestionTap: (id, smk) {
            FocusScope.of(context).unfocus();
            // Inga context-a pass panrom
            _emit(FWUpdateSmkSuggestionSelected(context: context, type: t, saleOrderId: id, smkText: smk));
          },
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _FieldLabel('EN Ref $t', isTablet),
        const SizedBox(height: 6),
        _FWTextField(
          controller: _enRefController,
          hint: 'EN.Ref $t',
          isTablet: isTablet,
          onChanged: (v) => _emit(FWUpdateEnRefChanged(type: t, value: v)),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _FieldLabel('EX Ref $t', isTablet),
        const SizedBox(height: 6),
        _FWTextField(
          controller: _exRefController,
          hint: 'EX.Ref $t',
          isTablet: isTablet,
          onChanged: (v) => _emit(FWUpdateExRefChanged(type: t, value: v)),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _FieldLabel('Seal By', isTablet),
        const SizedBox(height: 6),
        _EmployeeSearchField(
          hint: 'Seal By',
          value: tab.sealEmpName,
          isTablet: isTablet,
          onSearch: () async {
            context.read<FWUpdateBloc>().add(FWUpdateOverlayDismissed());
            await OnlineApi.SelectEmployee(context, '', 'Operation');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0)),
            ).then((_) {
              final sel = objfun.SelectEmployeeList;
              if (sel.Id != 0) {
                _emit(FWUpdateSealEmpChanged(type: t, empId: sel.Id, empName: sel.AccountName));
                objfun.SelectEmployeeList = EmployeeModel.Empty();
              }
            });
          },
          onClear: () => _emit(FWUpdateSealEmpCleared(t)),
        ),
        SizedBox(height: isTablet ? 16 : 12),

        _FieldLabel('Break Seal By', isTablet),
        const SizedBox(height: 6),
        _EmployeeSearchField(
          hint: 'B.Seal By',
          value: tab.breakEmpName,
          isTablet: isTablet,
          onSearch: () async {
            context.read<FWUpdateBloc>().add(FWUpdateOverlayDismissed());
            await OnlineApi.SelectEmployee(context, '', 'Operation');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0)),
            ).then((_) {
              final sel = objfun.SelectEmployeeList;
              if (sel.Id != 0) {
                _emit(FWUpdateBreakEmpChanged(type: t, empId: sel.Id, empName: sel.AccountName));
                objfun.SelectEmployeeList = EmployeeModel.Empty();
              }
            });
          },
          onClear: () => _emit(FWUpdateBreakEmpCleared(t)),
        ),
        SizedBox(height: isTablet ? 20 : 14),

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

// ─── SmkField WITH OVERLAY ──────────────────────────────────────────
class _SmkField extends StatefulWidget {
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
  State<_SmkField> createState() => _SmkFieldState();
}

class _SmkFieldState extends State<_SmkField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else if (widget.suggestions.isNotEmpty) {
        _showOverlay();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _SmkField oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.suggestions.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _showOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }

    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    var size = renderBox?.size ?? const Size(0, 0);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8.0,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.cardBorder, width: 0.5),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Palette.grey200p),
                itemBuilder: (ctx, i) {
                  final item = widget.suggestions[i];
                  final smkKey = widget.type == 1 ? 'ForwardingSMKNo' : widget.type == 2 ? 'ForwardingSMKNo2' : 'ForwardingSMKNo3';
                  final smkVal = item[smkKey]?.toString() ?? '';

                  return InkWell(
                    onTap: () {
                      _removeOverlay();
                      _focusNode.unfocus();
                      widget.onSuggestionTap(item['Id'], smkVal);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 16, color: Palette.blue400),
                          const SizedBox(width: 10),
                          Text(smkVal, style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: widget.isTablet ? objfun.FontLow + 1 : objfun.FontLow)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.characters,
        style: GoogleFonts.lato(
          color: Palette.textDark2,
          fontWeight: FontWeight.w600,
          fontSize: widget.isTablet ? objfun.FontLow + 1 : objfun.FontLow,
        ),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'SMK No ${widget.type}',
          hintStyle: GoogleFonts.lato(color: Palette.kTextMuted, fontSize: widget.isTablet ? objfun.FontLow + 1 : objfun.FontLow),
          filled: true,
          fillColor: Palette.grey200p,
          prefixIcon: const Icon(Icons.tag_rounded, color: Palette.blue400, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Palette.cardBorder, width: 0.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Palette.blue400, width: 1.5)),
        ),
      ),
    );
  }
}

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Palette.grey200p,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Palette.cardBorder, width: 0.5),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  context.read<FWUpdateBloc>().add(
                      FWUpdateImageUploadToggled(type: type, value: !tab.imageUploadEnabled));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: isTablet ? 22 : 18,
                  height: isTablet ? 22 : 18,
                  decoration: BoxDecoration(
                    gradient: tab.imageUploadEnabled ? kGradient : null,
                    border: tab.imageUploadEnabled ? null : Border.all(color: Palette.cardBorder, width: 1.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: tab.imageUploadEnabled ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 10),
              Text('Upload Image',
                style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: isTablet ? objfun.FontMedium + 1 : objfun.FontMedium),
              ),
              const Spacer(),
              _ImagePickBtn(icon: Icons.photo_outlined, enabled: tab.imageUploadEnabled, isTablet: isTablet, onTap: () => onPickImage(ImageSource.gallery, type, tab.smkText)),
              const SizedBox(width: 4),
              _ImagePickBtn(icon: Icons.camera_alt_outlined, enabled: tab.imageUploadEnabled, isTablet: isTablet, onTap: () => onPickImage(ImageSource.camera, type, tab.smkText)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: imgGridHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Palette.cardBorder, width: 0.5),
          ),
          child: tab.images.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: isTablet ? 48 : 36, color: Palette.kTextMuted),
                const SizedBox(height: 8),
                Text('No images uploaded', style: GoogleFonts.lato(color: Palette.kTextMuted, fontSize: 13)),
              ],
            ),
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridCols, crossAxisSpacing: 6, mainAxisSpacing: 6),
              itemCount: tab.images.length,
              itemBuilder: (ctx, index) {
                final imageUrl = '${objfun.imagepath}SalesOrder/$saleOrderId/${tab.smkText}/${tab.images[index]}';
                return InkWell(
                  onLongPress: () async {
                    final ok = await objfun.ConfirmationMsgYesNo(ctx, 'Are you sure to Delete ?');
                    if (ok == true) {
                      context.read<FWUpdateBloc>().add(FWUpdateImageDeleted(type: type, index: index));
                    }
                  },
                  onTap: () => objfun.launchInBrowser(imageUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Palette.grey200p, child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Palette.blue400, strokeWidth: 2)))),
                      errorWidget: (_, __, ___) => Container(color: Palette.grey200p, child: const Icon(Icons.file_copy_outlined, color: Palette.blue400)),
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

class _ImagePickBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isTablet;
  final VoidCallback onTap;

  const _ImagePickBtn({required this.icon, required this.enabled, required this.isTablet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () { FocusScope.of(context).unfocus(); onTap(); } : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: enabled ? Palette.blue700.withOpacity(0.08) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: isTablet ? 28 : 24, color: enabled ? Palette.blue700 : Palette.kTextMuted),
      ),
    );
  }
}

class _FWBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _FWBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Palette.cardBorder, width: 0.5))),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        selectedItemColor: Palette.blue700,
        unselectedItemColor: Palette.kTextMuted,
        selectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w700, fontSize: objfun.FontLow),
        unselectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w500, fontSize: objfun.FontCardText),
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'FW 1'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'FW 2'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'FW 3'),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const _FieldLabel(this.text, this.isTablet);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.lato(color: Palette.textMid, fontWeight: FontWeight.w600, fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow));
  }
}

class _EmployeeSearchField extends StatelessWidget {
  final String hint;
  final String value;
  final bool isTablet;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _EmployeeSearchField({required this.hint, required this.value, required this.isTablet, required this.onSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        value.isEmpty ? onSearch() : onClear();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: Palette.grey200p, borderRadius: BorderRadius.circular(10), border: Border.all(color: Palette.cardBorder, width: 0.5)),
        child: Row(
          children: [
            Expanded(child: Text(value.isEmpty ? hint : value, style: GoogleFonts.lato(color: value.isEmpty ? Palette.kTextMuted : Palette.textDark2, fontWeight: value.isEmpty ? FontWeight.w500 : FontWeight.w600, fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow), overflow: TextOverflow.ellipsis)),
            Icon(value.isNotEmpty ? Icons.close_rounded : Icons.search_rounded, size: 20, color: Palette.blue400),
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

  const _FWTextField({required this.controller, required this.hint, required this.isTablet, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(color: Palette.kTextMuted, fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
        filled: true,
        fillColor: Palette.grey200p,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Palette.cardBorder, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Palette.blue400, width: 1.5)),
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
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Text(label, style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: objfun.FontMedium))),
        ),
      ),
    );
  }
}