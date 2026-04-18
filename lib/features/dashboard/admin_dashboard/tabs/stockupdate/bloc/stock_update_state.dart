

abstract class StockUpdateState {}

class StockUpdateInitial extends StockUpdateState {}

class StockUpdateLoading extends StockUpdateState {}

class StockUpdateLoaded extends StockUpdateState {
  // ── Barcode / package counts ──────────────────────────────────────────────
  final String jobNo;       // BarcodeLabelDisplay (e.g. MY001)
  final int    totalPkg;    // NumberOfPackages from stock API
  final int    scnPkg;      // StockNoList.length (scanned count)
  final int    stockId;     // stock record Id
  final int?   status;      // stock Status field
  final int    saleOrderId;
  final int    jobId;       // JobMasterRefId

  // ── Scanned barcodes ──────────────────────────────────────────────────────
  final List<dynamic> stockNoList;      // barcodes accepted this session
  final List<dynamic> checkStockNoList; // expected barcodes (all pkg variants)

  // ── Boarding officer ──────────────────────────────────────────────────────
  final int    boardOfficerId1;
  final int    boardOfficerId2;
  final double boardOfficerAmt1;
  final double boardOfficerAmt2;

  // ── Warehouse ─────────────────────────────────────────────────────────────
  final int    warehouseId;
  final String warehouseName;

  // ── Status ────────────────────────────────────────────────────────────────
  final int    statusId;
  final String statusName;

  // ── Image ─────────────────────────────────────────────────────────────────
  final bool         imageUploadEnabled;
  final List<String> images;

   StockUpdateLoaded({
    required this.jobNo,
    required this.totalPkg,
    required this.scnPkg,
    required this.stockId,
    required this.status,
    required this.saleOrderId,
    required this.jobId,
    required this.stockNoList,
    required this.checkStockNoList,
    required this.boardOfficerId1,
    required this.boardOfficerId2,
    required this.boardOfficerAmt1,
    required this.boardOfficerAmt2,
    required this.warehouseId,
    required this.warehouseName,
    required this.statusId,
    required this.statusName,
    required this.imageUploadEnabled,
    required this.images,
  });

  factory StockUpdateLoaded.empty() =>  StockUpdateLoaded(
    jobNo:              '',
    totalPkg:           0,
    scnPkg:             0,
    stockId:            0,
    status:             0,
    saleOrderId:        0,
    jobId:              0,
    stockNoList:        [],
    checkStockNoList:   [],
    boardOfficerId1:    0,
    boardOfficerId2:    0,
    boardOfficerAmt1:   0.0,
    boardOfficerAmt2:   0.0,
    warehouseId:        0,
    warehouseName:      '',
    statusId:           0,
    statusName:         '',
    imageUploadEnabled: false,
    images:             [],
  );

  StockUpdateLoaded copyWith({
    String? jobNo,
    int?    totalPkg,
    int?    scnPkg,
    int?    stockId,
    int?    status,
    int?    saleOrderId,
    int?    jobId,
    List<dynamic>? stockNoList,
    List<dynamic>? checkStockNoList,
    int?    boardOfficerId1,
    int?    boardOfficerId2,
    double? boardOfficerAmt1,
    double? boardOfficerAmt2,
    int?    warehouseId,
    String? warehouseName,
    int?    statusId,
    String? statusName,
    bool?   imageUploadEnabled,
    List<String>? images,
  }) {
    return StockUpdateLoaded(
      jobNo:              jobNo              ?? this.jobNo,
      totalPkg:           totalPkg           ?? this.totalPkg,
      scnPkg:             scnPkg             ?? this.scnPkg,
      stockId:            stockId            ?? this.stockId,
      status:             status             ?? this.status,
      saleOrderId:        saleOrderId        ?? this.saleOrderId,
      jobId:              jobId              ?? this.jobId,
      stockNoList:        stockNoList        ?? this.stockNoList,
      checkStockNoList:   checkStockNoList   ?? this.checkStockNoList,
      boardOfficerId1:    boardOfficerId1    ?? this.boardOfficerId1,
      boardOfficerId2:    boardOfficerId2    ?? this.boardOfficerId2,
      boardOfficerAmt1:   boardOfficerAmt1   ?? this.boardOfficerAmt1,
      boardOfficerAmt2:   boardOfficerAmt2   ?? this.boardOfficerAmt2,
      warehouseId:        warehouseId        ?? this.warehouseId,
      warehouseName:      warehouseName      ?? this.warehouseName,
      statusId:           statusId           ?? this.statusId,
      statusName:         statusName         ?? this.statusName,
      imageUploadEnabled: imageUploadEnabled ?? this.imageUploadEnabled,
      images:             images             ?? this.images,
    );
  }
}

class StockUpdateSaveSuccess extends StockUpdateState {}

class StockUpdateError extends StockUpdateState {
  final String message;
  StockUpdateError(this.message);
}