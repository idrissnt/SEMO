import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/config/theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: AppTheme.headingMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 16),
              _buildCategoriesGrid(),
              const SizedBox(height: 24),
              Text(
                'Featured Products',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 16),
              _buildFeaturedProducts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {'name': 'Fruits', 'icon': Icons.apple},
      {'name': 'Vegetables', 'icon': Icons.eco},
      {'name': 'Dairy', 'icon': Icons.egg},
      {'name': 'Meat', 'icon': Icons.restaurant},
      {'name': 'Bakery', 'icon': Icons.bakery_dining},
      {'name': 'Beverages', 'icon': Icons.local_drink},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(
          categories[index]['name'] as String,
          categories[index]['icon'] as IconData,
        );
      },
    );
  }

  Widget _buildCategoryCard(String name, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product ${index + 1}',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${(index + 1) * 2.99}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
