class CategoryModel{
  // String CategoryId;
  String CategoryName;

  CategoryModel(this.CategoryName);
  factory CategoryModel.fromJson(Map<String,dynamic>json)=>CategoryModel(
    // json['CategoryId'],
    json['CategoryName'],
  );
  Map<String,dynamic> toJson()=>
      {
        // "CategoryId":CategoryId,
        "CategoryName":CategoryName
      };
}