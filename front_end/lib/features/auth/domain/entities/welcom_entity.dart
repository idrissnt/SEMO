class CompanyAsset {
  final String id;
  final String logoUrl;

  const CompanyAsset({
    required this.id,
    required this.logoUrl,
  });
}

class StoreAsset {
  final String id;
  final String titleOne;
  final String titleTwo;
  final String firstLogoUrl;
  final String secondLogoUrl;
  final String thirdLogoUrl;

  const StoreAsset({
    required this.id,
    required this.titleOne,
    required this.titleTwo,
    required this.firstLogoUrl,
    required this.secondLogoUrl,
    required this.thirdLogoUrl,
  });
}

class TaskAsset {
  final String id;
  final String titleOne;
  final String titleTwo;
  final String firstImage;
  final String secondImage;
  final String thirdImage;
  final String fourthImage;
  final String fifthImage;

  const TaskAsset({
    required this.id,
    required this.titleOne,
    required this.titleTwo,
    required this.firstImage,
    required this.secondImage,
    required this.thirdImage,
    required this.fourthImage,
    required this.fifthImage,
  });
}
