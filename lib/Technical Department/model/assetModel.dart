class AssetModel {
  // String AssetId;
  String AssetName;
  String CategoryName;

  AssetModel(this.AssetName, this.CategoryName);

  factory AssetModel.fromJson(Map<String, dynamic> json) =>
      AssetModel(
          // json['AssetId'],
          json['AssetName'],
          json['CategoryName']
      );

  Map<String, dynamic> toJson() =>
      {
        // "AssetId":AssetId,
        "AssetName":AssetName,
        "CategoryName":CategoryName,

      };
}
