abstract class FWUpdateState {}
class FWUpdateInitial extends FWUpdateState {}
class FWUpdateLoading extends FWUpdateState {}

class FWTabData {
  final String smkText;
  final String enRef;
  final String exRef;
  final int sealEmpId;
  final String sealEmpName;
  final int breakEmpId;
  final String breakEmpName;
  final bool imageUploadEnabled;
  final List<String> images;
  final List<dynamic> suggestions;

  const FWTabData({
    required this.smkText, required this.enRef, required this.exRef, required this.sealEmpId,
    required this.sealEmpName, required this.breakEmpId, required this.breakEmpName,
    required this.imageUploadEnabled, required this.images, required this.suggestions,
  });

  static FWTabData empty() => const FWTabData(
    smkText: '', enRef: '', exRef: '', sealEmpId: 0, sealEmpName: '', breakEmpId: 0,
    breakEmpName: '', imageUploadEnabled: false, images: [], suggestions: [],
  );

  FWTabData copyWith({
    String? smkText, String? enRef, String? exRef, int? sealEmpId, String? sealEmpName,
    int? breakEmpId, String? breakEmpName, bool? imageUploadEnabled, List<String>? images, List<dynamic>? suggestions,
  }) {
    return FWTabData(
      smkText: smkText ?? this.smkText, enRef: enRef ?? this.enRef, exRef: exRef ?? this.exRef,
      sealEmpId: sealEmpId ?? this.sealEmpId, sealEmpName: sealEmpName ?? this.sealEmpName,
      breakEmpId: breakEmpId ?? this.breakEmpId, breakEmpName: breakEmpName ?? this.breakEmpName,
      imageUploadEnabled: imageUploadEnabled ?? this.imageUploadEnabled, images: images ?? this.images,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

class FWUpdateLoaded extends FWUpdateState {
  final int currentTab;
  final int saleOrderId;
  final FWTabData tab1;
  final FWTabData tab2;
  final FWTabData tab3;

  FWUpdateLoaded({
    required this.currentTab, required this.saleOrderId, required this.tab1, required this.tab2, required this.tab3,
  });

  FWUpdateLoaded copyWith({
    int? currentTab, int? saleOrderId, FWTabData? tab1, FWTabData? tab2, FWTabData? tab3,
  }) {
    return FWUpdateLoaded(
      currentTab: currentTab ?? this.currentTab, saleOrderId: saleOrderId ?? this.saleOrderId,
      tab1: tab1 ?? this.tab1, tab2: tab2 ?? this.tab2, tab3: tab3 ?? this.tab3,
    );
  }

  FWTabData tabByType(int type) {
    switch (type) { case 1: return tab1; case 2: return tab2; default: return tab3; }
  }

  FWUpdateLoaded withTab(int type, FWTabData data) {
    switch (type) { case 1: return copyWith(tab1: data); case 2: return copyWith(tab2: data); default: return copyWith(tab3: data); }
  }
}

class FWUpdateError extends FWUpdateState {
  final String message;
  FWUpdateError(this.message);
}
class FWUpdateSaveSuccess extends FWUpdateState {}
class FWUpdateShowImagePreview extends FWUpdateState {
  final int type, index;
  final String imageUrl;
  FWUpdateShowImagePreview({required this.type, required this.index, required this.imageUrl});
}