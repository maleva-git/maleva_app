
class SubscriptionKey {
  String MobileNo;
  String ShopName;
  String Email;
  String KeyType;
  String ProductKey;
  String ComputuerId;
  String TokenId;
  String Licence;
  String LicenceDate;
  String LastVerifitedDate;
  String SyncDate;
  String AmcStatus;
  String LicenceNo;
  String Trial;
  SubscriptionKey(
      this.MobileNo,
      this.ShopName,
      this.Email,
      this.KeyType,
      this.ProductKey,
      this.ComputuerId,
      this.TokenId,
      this.Licence,
      this.LicenceDate,
      this.LastVerifitedDate,
      this.SyncDate,
      this.AmcStatus,
      this.LicenceNo,
      this.Trial);
  SubscriptionKey.fromJson(Map<String, dynamic> json)
      : MobileNo = json['MobileNo'].toString(),
        ShopName = json['ShopName'].toString(),
        Email = json['Email'].toString(),
        KeyType = json['KeyType'].toString(),
        ProductKey = json['ProductKey'].toString(),
        ComputuerId = json['ComputuerId'].toString(),
        TokenId = json['TokenId'].toString(),
        Licence = json['Licence'].toString(),
        LicenceDate = json['LicenceDate'].toString(),
        LastVerifitedDate = json['LastVerifitedDate'].toString(),
        SyncDate = json['SyncDate'].toString(),
        AmcStatus = json['AmcStatus'].toString(),
        LicenceNo = json['LicenceNo'].toString(),
        Trial = json['Trial'].toString();
}