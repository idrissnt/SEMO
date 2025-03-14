# class StoreProductWithStoreSerializer(serializers.ModelSerializer):
#     product = ProductSerializer(read_only=True)
#     store = serializers.SerializerMethodField()

#     class Meta:
#         model = StoreProduct
#         fields = ['product', 'price', 'store']

#     def get_store(self, obj):
#         # Return minimal store details
#         return {
#             "id": obj.store.id,
#             "name": obj.store.name,
#             "slug": obj.store.slug,
#             "city": obj.store.city
#         }
