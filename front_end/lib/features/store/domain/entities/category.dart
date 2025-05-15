/// Domain entity representing a store category
class Category {
  final String id;
  final String name;
  final String slug;
  final String path; // Hierarchical path (e.g., "fruits_et_legumes.fruits")
  final String? description;
  final String storeBrandId;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.path,
    required this.storeBrandId,
    this.description,
  });

  @override
  String toString() => name;

  /// Returns the parent category path or null if this is a root category
  String? get parentPath {
    final lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex == -1) return null;
    return path.substring(0, lastDotIndex);
  }

  /// Returns the category level in the hierarchy (0 for root categories)
  int get level => path.split('.').length - 1;
}
