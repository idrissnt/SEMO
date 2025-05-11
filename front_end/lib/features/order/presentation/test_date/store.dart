import 'package:semo/features/store/domain/entities/store.dart';

final stores = [
  StoreBrand(
    id: '1',
    name: 'E.Leclerc',
    slug: 'store-1',
    type: 'type 1',
    imageLogo:
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/ELeclerc-logo-home.png',
    imageBanner: 'https://via.placeholder.com/300x150',
  ),
  StoreBrand(
    id: '2',
    name: 'Carrefour',
    slug: 'store-2',
    type: 'type 2',
    imageLogo:
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Carrefour-logo-home.png',
    imageBanner: 'https://via.placeholder.com/300x150',
  ),
  StoreBrand(
    id: '3',
    name: 'Lidl',
    slug: 'store-3',
    type: 'type 3',
    imageLogo:
        'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
    imageBanner: 'https://via.placeholder.com/300x150',
  ),
];
