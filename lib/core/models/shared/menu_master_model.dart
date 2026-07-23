
class MenuMasterModel {
  String FormText;
  int Id;
  int CompanyRefid;
  int ParentId;
  int PageAdd;
  int PageEdit;
  int PageDelete;
  int PageView;

  MenuMasterModel(this.FormText, this.Id, this.CompanyRefid, this.ParentId,
      this.PageAdd, this.PageEdit, this.PageDelete, this.PageView);

  MenuMasterModel.fromJson(Map<String, dynamic> json)
      : FormText = json['FormText'] ?? '',
        Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CompanyRefid = int.tryParse(json['CompanyRefid']?.toString() ?? '') ?? 0,
        ParentId = int.tryParse(json['ParentId']?.toString() ?? '') ?? 0,
        PageAdd = int.tryParse(json['PageAdd']?.toString() ?? '') ?? 0,
        PageEdit = int.tryParse(json['PageEdit']?.toString() ?? '') ?? 0,
        PageDelete = int.tryParse(json['PageDelete']?.toString() ?? '') ?? 0,
        PageView = int.tryParse(json['PageView']?.toString() ?? '') ?? 0;

  // method
  Map<String, dynamic> toJson() {
    return {
      'FormText': FormText,
      'ParentId': ParentId,
      'Id': Id,
      'CompanyRefid': CompanyRefid,
      'PageAdd': PageAdd,
      'PageEdit': PageEdit,
      'PageDelete': PageDelete,
      'PageView': PageView,
    };
  }

  MenuMasterModel.Empty()
      : FormText = '',
        Id = 0,
        CompanyRefid = 0,
        ParentId = 0,
        PageAdd = 0,
        PageEdit = 0,
        PageDelete = 0,
        PageView = 0;
}