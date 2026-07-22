
class ReviewModel {
  String ShopName;
  String ShopNumper;
  String EngRemarks;
  String Remarks;
  String Issue;
  int TicketNo;
  String Support_Date;
  String ReviewRemarks;
  int Id;

  ReviewModel(
      this.ShopName,
      this.ReviewRemarks,
      this.ShopNumper,
      this.EngRemarks,
      this.Remarks,
      this.Issue,
      this.TicketNo,
      this.Support_Date,
      this.Id);

  ReviewModel.fromJson(Map<String, dynamic> json)
      : TicketNo = int.tryParse(json['TicketNo']?.toString() ?? '') ?? 0,
        ShopName = json['ShopName'].toString(),
        ShopNumper = json['ShopNumper'].toString(),
        EngRemarks = json['EngRemarks'].toString(),
        Remarks = json['Remarks'].toString(),
        ReviewRemarks = json['Remarks'].toString(),
        Issue = json['Issue'].toString(),
        Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        Support_Date = json['Support_Date'].toString();
  Map<String, dynamic> toJson() {
    return {
      'TicketNo': TicketNo,
      'ShopName': ShopName,
      'ShopNumper': ShopNumper,
      'EngRemarks': EngRemarks,
      'Remarks': Remarks,
      'ReviewRemarks': ReviewRemarks,
      'Issue': Issue,
      'Id': Id,
      'Support_Date': Support_Date,
    };
  }
}