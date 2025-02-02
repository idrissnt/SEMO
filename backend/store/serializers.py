from rest_framework.serializers import ModelSerializer
from rest_framework import serializers
from store.models import Store,Article,Product,Category

class ArticleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Article
        fields = ['id', 'name', 'image', 'price']

class ProductListSerializer(serializers.ModelSerializer):
    articles = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ['id', 'name','articles']

class ProductDetailSerializer(serializers.ModelSerializer):
    articles = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ['id', 'name','articles']
    def  get_articles(self,instance) :
        queryset = instance.articles.filter(stock__gt=0)
        serializer = ArticleSerializer(queryset, many=True)
        # la propriété '.data' est le rendu de notre serializer que nous retournons ici
        return serializer.data    
class CategoryListSerializer(serializers.ModelSerializer):

    class Meta:
        model = Category
        fields = ['id', 'name', 'image','products']

class CategoryDetailSerializer(serializers.ModelSerializer):

    products = serializers.SerializerMethodField()
    class Meta:
        model = Category
        fields = ['id', 'name', 'image','products']
    # En utilisant un `SerializerMethodField', il est nécessaire d'écrire une méthode
    # nommée 'get_XXX' où XXX est le nom de l'attribut, ici 'products'
    def get_products(self, instance):
        # Le paramètre 'instance' est l'instance de la catégorie consultée.
        # Dans le cas d'une liste, cette méthode est appelée autant de fois qu'il y a
        # d'entités dans la liste

        # On applique le filtre sur notre queryset pour n'avoir que les produits actifs
        queryset = instance.products.filter(active=True)
        # Le serializer est créé avec le queryset défini et toujours défini en tant que many=True
        serializer = ProductSerializer(queryset, many=True)
        # la propriété '.data' est le rendu de notre serializer que nous retournons ici
        return serializer.data    

class ShopStoreListSerializer(serializers.ModelSerializer) :
    class Meta :
        model = Store
        fields = ['id', 'name', 'image' ]

class ShopStoreDetailSerializer(serializers.ModelSerializer):

    categories_in_category = serializers.SerializerMethodField()
    class Meta:
        model = Store
        fields = ['id', 'name', 'image', 'categories_in_category']
    def get_categories_in_category(self,instance) :
        queryset= instance.categories_in_category.filter(active=True)
        serializer= CategorySerializer(queryset, many=True)
        return serializer.data
    
