import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/domain/entities/store.dart';

/// Mock data for store categories, subcategories, and products
///
///
///

//
//
//
//
//
class StoreWithCategoryProducts {
  /// Get mock aisles data
  static List<StoreBrand> getMockStoreBrands() {
    return [
      StoreBrand(
        id: '1',
        name: 'Lidl',
        slug: 'lidl',
        type: 'supermarket',
        imageLogo:
            'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
        imageBanner:
            'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/store_baners/baner.webp',
        aisles: [freshProduce],
      ),
      StoreBrand(
        id: '1',
        name: 'Carrefour',
        slug: 'carrefour',
        type: 'hypermarket',
        imageLogo:
            'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/carrefoures-log-for-cart.jpeg',
        imageBanner:
            'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/store_baners/baner.webp',
        aisles: [dairyAndEggs],
      ),
      StoreBrand(
        id: '1',
        name: 'E.Leclerc',
        slug: 'e-leclerc',
        type: 'hypermarket',
        imageLogo:
            'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/for-cart/E-Leclerc-logo-for-cart.png',
        imageBanner:
            'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/store_baners/baner.webp',
        aisles: [bakery],
      ),
    ];
  }
}
//
//
//
//
//

//
//
//
//
//

StoreAisle freshProduce = StoreAisle(
  id: 'cat-001',
  name: 'Fresh Produce',
  imageUrl:
      'https://images.unsplash.com/photo-1610348725531-843dff563e2c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
  description: 'Fresh fruits and vegetables',
  categories: [
    // Fruits Subcategory
    AisleCategory(
      id: 'sub-001',
      aisleId: 'cat-001',
      name: 'Fruits',
      imageUrl:
          'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      description: 'Fresh seasonal fruits',
      products: [
        CategoryProduct(
          id: 'prod-001',
          name: 'Organic Bananas',
          imageUrl:
              'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 1.99,
          pricePerUnit: 2.5,
          productUnit: 'bunch',
          unit: 'bunch',
          ingredient: 'Organic bananas, perfect for smoothies and snacks',
        ),
        CategoryProduct(
          id: 'prod-002',
          name: 'Red Apples',
          imageUrl:
              'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 0.79,
          pricePerUnit: 1,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Sweet and crisp red apples',
        ),
        CategoryProduct(
          id: 'prod-003',
          name: 'Strawberries',
          imageUrl:
              'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 3.99,
          pricePerUnit: 4.99,
          productUnit: 'pack',
          unit: 'pack',
          ingredient: 'Sweet and juicy strawberries',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
        CategoryProduct(
          id: 'prod-004',
          name: 'Avocados',
          imageUrl:
              'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Ripe and ready to eat avocados',
        ),
      ],
    ),
    // Vegetables Subcategory
    AisleCategory(
      id: 'sub-002',
      aisleId: 'cat-001',
      name: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      description: 'Fresh seasonal vegetables',
      products: [
        CategoryProduct(
          id: 'prod-005',
          name: 'Broccoli',
          imageUrl:
              'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 1.49,
          pricePerUnit: 1.49,
          productUnit: 'head',
          unit: 'head',
          ingredient: 'Fresh broccoli, rich in vitamins and minerals',
        ),
        CategoryProduct(
          id: 'prod-006',
          name: 'Carrots',
          imageUrl:
              'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 0.99,
          pricePerUnit: 0.99,
          productUnit: 'lb',
          unit: 'lb',
          ingredient: 'Fresh carrots, perfect for snacking or cooking',
        ),
        CategoryProduct(
          id: 'prod-007',
          name: 'Spinach',
          imageUrl:
              'https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.99,
          pricePerUnit: 2.99,
          productUnit: 'bag',
          unit: 'bag',
          ingredient: 'Fresh spinach, perfect for salads and smoothies',
        ),
      ],
    ),
  ],
);

//
//
//
//
//
//
//
StoreAisle dairyAndEggs = StoreAisle(
  id: 'aisle-002',
  name: 'Dairy & Eggs',
  imageUrl:
      'https://images.unsplash.com/photo-1628088062854-d1870b4553da?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
  description: 'Fresh dairy products and eggs',
  categories: [
    // Milk & Cream Subcategory
    AisleCategory(
      id: 'sub-003',
      aisleId: 'aisle-002',
      name: 'Milk & Cream',
      imageUrl:
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      description: 'Fresh milk and cream products',
      products: [
        CategoryProduct(
          id: 'prod-008',
          name: 'Whole Milk',
          imageUrl:
              'https://images.unsplash.com/photo-1576186726115-4d51596775d1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 3.49,
          pricePerUnit: 3.49,
          productUnit: 'gallon',
          unit: 'gallon',
          ingredient: 'Fresh whole milk',
        ),
        CategoryProduct(
          id: 'prod-009',
          name: 'Almond Milk',
          imageUrl:
              'https://images.unsplash.com/photo-1600788907416-456578634209?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 3.99,
          pricePerUnit: 3.99,
          productUnit: 'half gallon',
          unit: 'half gallon',
          ingredient: 'Unsweetened almond milk',
        ),
        CategoryProduct(
          id: 'prod-010',
          name: 'Heavy Cream',
          imageUrl:
              'https://images.unsplash.com/photo-1587657565520-6c0c825f3d3a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 4.29,
          pricePerUnit: 4.29,
          productUnit: 'pint',
          unit: 'pint',
          ingredient: 'Fresh heavy cream, perfect for cooking and baking',
        ),
      ],
    ),
    // Cheese Subcategory
    AisleCategory(
      id: 'sub-004',
      aisleId: 'aisle-002',
      name: 'Cheese',
      imageUrl:
          'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      description: 'Variety of cheeses',
      products: [
        CategoryProduct(
          id: 'prod-011',
          name: 'Cheddar Cheese',
          imageUrl:
              'https://images.unsplash.com/photo-1618164436241-4473940d1f5c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 4.99,
          pricePerUnit: 4.99,
          productUnit: 'block',
          unit: 'block',
          ingredient: 'Sharp cheddar cheese',
        ),
        CategoryProduct(
          id: 'prod-012',
          name: 'Mozzarella',
          imageUrl:
              'https://images.unsplash.com/photo-1551489186-cf8726f514f8?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 3.99,
          pricePerUnit: 3.99,
          productUnit: 'pack',
          unit: 'pack',
          ingredient: 'Fresh mozzarella cheese',
        ),
        CategoryProduct(
          id: 'prod-013',
          name: 'Parmesan',
          imageUrl:
              'https://images.unsplash.com/photo-1528747045269-390fe33c19f2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 5.99,
          pricePerUnit: 5.99,
          productUnit: 'wedge',
          unit: 'wedge',
          ingredient: 'Aged parmesan cheese',
        ),
      ],
    ),
    // Eggs Subcategory
    AisleCategory(
      id: 'sub-005',
      aisleId: 'aisle-002',
      name: 'Eggs',
      imageUrl:
          'https://images.unsplash.com/photo-1509479100390-f83a8349e79c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      description: 'Fresh eggs',
      products: [
        CategoryProduct(
          id: 'prod-014',
          name: 'Large Eggs',
          imageUrl:
              'https://images.unsplash.com/photo-1587486913049-53fc88980cfc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.99,
          pricePerUnit: 2.99,
          productUnit: 'dozen',
          unit: 'dozen',
          ingredient: 'Farm fresh large eggs',
        ),
        CategoryProduct(
          id: 'prod-015',
          name: 'Organic Eggs',
          imageUrl:
              'https://images.unsplash.com/photo-1498654077810-12c21d4d6dc3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 4.99,
          pricePerUnit: 4.99,
          productUnit: 'dozen',
          unit: 'dozen',
          ingredient: 'Organic free-range eggs',
        ),
      ],
    ),
  ],
);

//
//
//
//
//
//

StoreAisle bakery = // Bakery Category
    StoreAisle(
  id: 'aisle-003',
  name: 'Bakery',
  imageUrl:
      'https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
  description: 'Fresh baked goods',
  categories: [
    // Bread Subcategory
    AisleCategory(
      id: 'sub-006',
      aisleId: 'aisle-003',
      name: 'Bread',
      imageUrl:
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc7c?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      description: 'Fresh baked bread',
      products: [
        CategoryProduct(
          id: 'prod-016',
          name: 'Sourdough Bread',
          imageUrl:
              'https://images.unsplash.com/photo-1585478259715-1c093a7b7d3a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 4.49,
          pricePerUnit: 4.49,
          productUnit: 'loaf',
          unit: 'loaf',
          ingredient: 'Freshly baked sourdough bread',
        ),
        CategoryProduct(
          id: 'prod-017',
          name: 'Whole Wheat Bread',
          imageUrl:
              'https://images.unsplash.com/photo-1598373182133-52452f7691ef?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 3.99,
          pricePerUnit: 3.99,
          productUnit: 'loaf',
          unit: 'loaf',
          ingredient: 'Freshly baked whole wheat bread',
        ),
        CategoryProduct(
          id: 'prod-018',
          name: 'Baguette',
          imageUrl:
              'https://images.unsplash.com/photo-1597079910443-60c43fc5b7b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.99,
          pricePerUnit: 2.99,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Freshly baked French baguette',
        ),
      ],
    ),
    // Pastries Subcategory
    AisleCategory(
      id: 'sub-007',
      aisleId: 'aisle-003',
      name: 'Pastries',
      imageUrl:
          'https://images.unsplash.com/photo-1517433367423-c7e5b0f35086?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      description: 'Fresh baked pastries',
      products: [
        CategoryProduct(
          id: 'prod-019',
          name: 'Croissants',
          imageUrl:
              'https://images.unsplash.com/photo-1555507036-ab1f4038808a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 1.99,
          pricePerUnit: 1.99,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Freshly baked butter croissants',
        ),
        CategoryProduct(
          id: 'prod-020',
          name: 'Chocolate Muffins',
          imageUrl:
              'https://images.unsplash.com/photo-1604882406385-6eb3f54eb4c3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 2.49,
          pricePerUnit: 2.49,
          productUnit: 'each',
          unit: 'each',
          ingredient: 'Freshly baked chocolate muffins',
        ),
        CategoryProduct(
          id: 'prod-021',
          name: 'Cinnamon Rolls',
          imageUrl:
              'https://images.unsplash.com/photo-1583527976767-a57cdcbcd5ac?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          price: 3.49,
          pricePerUnit: 3.49,
          productUnit: 'pack of 4',
          unit: 'pack of 4',
          ingredient: 'Freshly baked cinnamon rolls',
        ),
      ],
    ),
  ],
);
