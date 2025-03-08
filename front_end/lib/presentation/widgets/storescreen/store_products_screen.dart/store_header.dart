import 'package:flutter/material.dart';
import '../../../../data/models/store/store_model.dart';

class StoreHeader extends StatelessWidget {
  final StoreModel store;

  const StoreHeader({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 60.0), // Add padding to position below app bar
      alignment: Alignment.center,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: ClipOval(
            child: Image.network(
              store.logoUrl ?? 'https://via.placeholder.com/100',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.store,
                  size: 60,
                  color: Colors.blue,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
