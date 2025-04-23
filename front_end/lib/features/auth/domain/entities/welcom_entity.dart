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
  final String cardTitleOne;
  final String cardTitleTwo;
  final String storeTitle;
  final String storeLogoOneUrl;
  final String storeLogoTwoUrl;
  final String storeLogoThreeUrl;

  const StoreAsset({
    required this.id,
    required this.cardTitleOne,
    required this.cardTitleTwo,
    required this.storeTitle,
    required this.storeLogoOneUrl,
    required this.storeLogoTwoUrl,
    required this.storeLogoThreeUrl,
  });
}

class TaskAsset {
  final String id;
  final String title;
  final String taskImage;
  final String taskerProfileImageUrl;
  final String taskerProfileTitle;

  const TaskAsset({
    required this.id,
    required this.title,
    required this.taskImage,
    required this.taskerProfileImageUrl,
    required this.taskerProfileTitle,
  });
}
