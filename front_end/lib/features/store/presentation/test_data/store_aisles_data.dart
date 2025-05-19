import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/domain/entities/store.dart';

/// Mock data for store categories, subcategories, and products
///
///
///

StoreBrand storeBrandData = StoreBrand(
  id: '1',
  name: 'Sample Store',
  slug: 'sample-store', // Add required slug parameter
  type: 'grocery', // Add required type parameter
  imageLogo:
      'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/logo/Lidl-logo-home.png',
  imageBanner:
      'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/store_baners/baner.webp',
);

///
///
class StoreAisleData {
  /// Get mock aisles data
  static List<StoreAisle> getMockAisles() {
    return [
      // Fresh Produce Category
      StoreAisle(
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
                unit: 'bunch',
                description:
                    'Organic bananas, perfect for smoothies and snacks',
              ),
              CategoryProduct(
                id: 'prod-002',
                name: 'Red Apples',
                imageUrl:
                    'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 0.79,
                unit: 'each',
                description: 'Sweet and crisp red apples',
              ),
              CategoryProduct(
                id: 'prod-003',
                name: 'Strawberries',
                imageUrl:
                    'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 3.99,
                originalPrice: 4.99,
                unit: 'pack',
                description: 'Sweet and juicy strawberries',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
              ),
              CategoryProduct(
                id: 'prod-004',
                name: 'Avocados',
                imageUrl:
                    'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Ripe and ready to eat avocados',
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
                unit: 'head',
                description: 'Fresh broccoli, rich in vitamins and minerals',
              ),
              CategoryProduct(
                id: 'prod-006',
                name: 'Carrots',
                imageUrl:
                    'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 0.99,
                unit: 'lb',
                description: 'Fresh carrots, perfect for snacking or cooking',
              ),
              CategoryProduct(
                id: 'prod-007',
                name: 'Spinach',
                imageUrl:
                    'https://images.unsplash.com/photo-1576045057995-568f588f82fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.99,
                unit: 'bag',
                description: 'Fresh spinach, perfect for salads and smoothies',
              ),
            ],
          ),
        ],
      ),

      // Dairy & Eggs Category
      StoreAisle(
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
                unit: 'gallon',
                description: 'Fresh whole milk',
              ),
              CategoryProduct(
                id: 'prod-009',
                name: 'Almond Milk',
                imageUrl:
                    'https://images.unsplash.com/photo-1600788907416-456578634209?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 3.99,
                unit: 'half gallon',
                description: 'Unsweetened almond milk',
              ),
              CategoryProduct(
                id: 'prod-010',
                name: 'Heavy Cream',
                imageUrl:
                    'https://images.unsplash.com/photo-1587657565520-6c0c825f3d3a?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 4.29,
                unit: 'pint',
                description:
                    'Fresh heavy cream, perfect for cooking and baking',
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
                unit: 'block',
                description: 'Sharp cheddar cheese',
              ),
              CategoryProduct(
                id: 'prod-012',
                name: 'Mozzarella',
                imageUrl:
                    'https://images.unsplash.com/photo-1551489186-cf8726f514f8?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 3.99,
                unit: 'pack',
                description: 'Fresh mozzarella cheese',
              ),
              CategoryProduct(
                id: 'prod-013',
                name: 'Parmesan',
                imageUrl:
                    'https://images.unsplash.com/photo-1528747045269-390fe33c19f2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 5.99,
                unit: 'wedge',
                description: 'Aged parmesan cheese',
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
                unit: 'dozen',
                description: 'Farm fresh large eggs',
              ),
              CategoryProduct(
                id: 'prod-015',
                name: 'Organic Eggs',
                imageUrl:
                    'https://images.unsplash.com/photo-1498654077810-12c21d4d6dc3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 4.99,
                originalPrice: 5.99,
                unit: 'dozen',
                description: 'Organic free-range eggs',
              ),
            ],
          ),
        ],
      ),

      // Bakery Category
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
                unit: 'loaf',
                description: 'Freshly baked sourdough bread',
              ),
              CategoryProduct(
                id: 'prod-017',
                name: 'Whole Wheat Bread',
                imageUrl:
                    'https://images.unsplash.com/photo-1598373182133-52452f7691ef?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 3.99,
                unit: 'loaf',
                description: 'Freshly baked whole wheat bread',
              ),
              CategoryProduct(
                id: 'prod-018',
                name: 'Baguette',
                imageUrl:
                    'https://images.unsplash.com/photo-1597079910443-60c43fc5b7b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.99,
                unit: 'each',
                description: 'Freshly baked French baguette',
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
                unit: 'each',
                description: 'Freshly baked butter croissants',
              ),
              CategoryProduct(
                id: 'prod-020',
                name: 'Chocolate Muffins',
                imageUrl:
                    'https://images.unsplash.com/photo-1604882406385-6eb3f54eb4c3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.49,
                unit: 'each',
                description: 'Freshly baked chocolate muffins',
              ),
              CategoryProduct(
                id: 'prod-021',
                name: 'Cinnamon Rolls',
                imageUrl:
                    'https://images.unsplash.com/photo-1583527976767-a57cdcbcd5ac?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 3.49,
                originalPrice: 3.99,
                unit: 'pack of 4',
                description: 'Freshly baked cinnamon rolls',
              ),
            ],
          ),
        ],
      ),

      // Meat & Seafood Category
      StoreAisle(
        id: 'aisle-004',
        name: 'Meat & Seafood',
        imageUrl:
            'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        description: 'Fresh meat and seafood',
        categories: [
          // Beef Subcategory
          AisleCategory(
            id: 'sub-008',
            aisleId: 'aisle-004',
            name: 'Beef',
            imageUrl:
                'https://images.unsplash.com/photo-1551028150-64b9f398f678?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            description: 'Fresh beef cuts',
            products: [
              CategoryProduct(
                id: 'prod-022',
                name: 'Ground Beef',
                imageUrl:
                    'https://images.unsplash.com/photo-1588168333986-5078d3ae3976?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 5.99,
                unit: 'lb',
                description: 'Fresh ground beef, 85% lean',
              ),
              CategoryProduct(
                id: 'prod-023',
                name: 'Ribeye Steak',
                imageUrl:
                    'https://images.unsplash.com/photo-1588167047098-c8e3a901657d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 14.99,
                unit: 'lb',
                description: 'Prime ribeye steak',
              ),
            ],
          ),
          // Poultry Subcategory
          AisleCategory(
            id: 'sub-009',
            aisleId: 'aisle-004',
            name: 'Poultry',
            imageUrl:
                'https://images.unsplash.com/photo-1587593810167-a84920ea0781?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            description: 'Fresh poultry',
            products: [
              CategoryProduct(
                id: 'prod-024',
                name: 'Chicken Breast',
                imageUrl:
                    'https://images.unsplash.com/photo-1604503468506-a8da13d82791?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 4.99,
                unit: 'lb',
                description: 'Boneless, skinless chicken breast',
              ),
              CategoryProduct(
                id: 'prod-025',
                name: 'Whole Chicken',
                imageUrl:
                    'https://images.unsplash.com/photo-1501200291289-c5a76c232e5f?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 7.99,
                unit: 'each',
                description: 'Fresh whole chicken',
              ),
            ],
          ),
          // Seafood Subcategory
          AisleCategory(
            id: 'sub-010',
            aisleId: 'aisle-004',
            name: 'Seafood',
            imageUrl:
                'https://images.unsplash.com/photo-1498654077810-12c21d4d6dc3?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            description: 'Fresh seafood',
            products: [
              CategoryProduct(
                id: 'prod-026',
                name: 'Atlantic Salmon',
                imageUrl:
                    'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 12.99,
                unit: 'lb',
                description: 'Fresh Atlantic salmon fillet',
              ),
              CategoryProduct(
                id: 'prod-027',
                name: 'Shrimp',
                imageUrl:
                    'https://images.unsplash.com/photo-1565680018160-64b74e0186b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 14.99,
                originalPrice: 16.99,
                unit: 'lb',
                description: 'Large peeled and deveined shrimp',
              ),
            ],
          ),
        ],
      ),

      // Pantry & Dry Goods Category
      StoreAisle(
        id: 'aisle-005',
        name: 'Pantry & Dry Goods',
        imageUrl:
            'https://images.unsplash.com/photo-1584473457493-17c4c24290b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        description: 'Pantry staples and dry goods',
        categories: [
          // Pasta & Rice Subcategory
          AisleCategory(
            id: 'sub-011',
            aisleId: 'aisle-005',
            name: 'Pasta & Rice',
            imageUrl:
                'https://images.unsplash.com/photo-1556761223-4c4282c73f77?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            description: 'Pasta, rice, and grains',
            products: [
              CategoryProduct(
                id: 'prod-028',
                name: 'Spaghetti',
                imageUrl:
                    'https://images.unsplash.com/photo-1551462147-ff29053bfc14?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 1.99,
                unit: 'box',
                description: 'Dried spaghetti pasta',
              ),
              CategoryProduct(
                id: 'prod-029',
                name: 'Jasmine Rice',
                imageUrl:
                    'https://images.unsplash.com/photo-1586201375761-83865001e8ac?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 4.99,
                unit: '2 lb bag',
                description: 'Premium jasmine rice',
              ),
            ],
          ),
          // Canned Goods Subcategory
          AisleCategory(
            id: 'sub-012',
            aisleId: 'aisle-005',
            name: 'Canned Goods',
            imageUrl:
                'https://images.unsplash.com/photo-1584473457493-17c4c24290b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            description: 'Canned foods and soups',
            products: [
              CategoryProduct(
                id: 'prod-030',
                name: 'Canned Tomatoes',
                imageUrl:
                    'https://images.unsplash.com/photo-1589927986089-35812388d1f4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 1.49,
                unit: 'can',
                description: 'Diced canned tomatoes',
              ),
              CategoryProduct(
                id: 'prod-031',
                name: 'Chicken Noodle Soup',
                imageUrl:
                    'https://images.unsplash.com/photo-1547592166-23ac45744acd?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 2.29,
                unit: 'can',
                description: 'Classic chicken noodle soup',
              ),
            ],
          ),
        ],
      ),

      // Beverages Category
      StoreAisle(
        id: 'aisle-006',
        name: 'Beverages',
        imageUrl:
            'https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
        description: 'Drinks and beverages',
        categories: [
          // Coffee & Tea Subcategory
          AisleCategory(
            id: 'sub-013',
            aisleId: 'aisle-006',
            name: 'Coffee & Tea',
            imageUrl:
                'https://images.unsplash.com/photo-1544787219-7f47ccb76574?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            description: 'Coffee, tea, and related products',
            products: [
              CategoryProduct(
                id: 'prod-032',
                name: 'Ground Coffee',
                imageUrl:
                    'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 8.99,
                unit: '12 oz bag',
                description: 'Medium roast ground coffee',
              ),
              CategoryProduct(
                id: 'prod-033',
                name: 'Green Tea',
                imageUrl:
                    'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 4.99,
                unit: 'box',
                description: 'Organic green tea, 20 tea bags',
              ),
            ],
          ),
          // Soft Drinks Subcategory
          AisleCategory(
            id: 'sub-014',
            aisleId: 'aisle-006',
            name: 'Soft Drinks',
            imageUrl:
                'https://images.unsplash.com/photo-1581636625402-29b2a704ef13?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            description: 'Sodas and soft drinks',
            products: [
              CategoryProduct(
                id: 'prod-034',
                name: 'Cola',
                imageUrl:
                    'https://images.unsplash.com/photo-1554866585-cd94860890b7?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 1.99,
                unit: '2L bottle',
                description: 'Classic cola soda',
              ),
              CategoryProduct(
                id: 'prod-035',
                name: 'Sparkling Water',
                imageUrl:
                    'https://images.unsplash.com/photo-1560508179-b2c9a3f8e92b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                price: 0.99,
                unit: 'can',
                description: 'Lime flavored sparkling water',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
