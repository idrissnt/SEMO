from django.db import models

# Create your models here.

class Store(models.Model):
    image=models.ImageField()
    class Name (models.TextChoices) :
        AUCHAN= 'Auchan'
        LIDL = 'Lidl'
        CARREFOUR = 'Carrefour'
        E_LECLERC ='E.Leclerc'
        INTERMARCHE = 'Intermarché'

    name = models.CharField(choices=Name.choices,max_length=100)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.0)
    is_popular = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    active = models.BooleanField(default=False)

    class Meta:
        ordering = ['-rating', 'name']
        indexes = [
            models.Index(fields=['rating']),
            models.Index(fields=['is_popular']),
        ]

    def __str__(self):
        return self.name

class Category(models.Model):

    image = models.ImageField( blank=False, null=False)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    class Rayons (models.TextChoices) :
        Prouits_laitiers_oeufs_fromage = 'Produits laitiers, oeufs, fromages'
        Fruits_legumes = 'Fruits, légumes'
        Boucherie_volaille_poissonnerie = 'Boucherie, volaille, poissonnerie'
        Charcuterie_traiteur ='Charcuterie,traiteur'
        Pain_patisserie = 'Pain, pâtisserie'
        Surgeles ='Surgelés'
        Epicerie_sucree = 'Epicerie,sucrée'
        Epicerie_salee = 'Epicerie_salée'
        Eaux_jus_soda_thes_glaces = 'Eaux,jus,soda,thès glaces'
        Vins_bieres_alcools ='Vins, bières, alcools'
        Hygiene_beaute = 'Hygiène,beauté '
        Entretien_accessoires_de_maison = 'Entretien, accessoires de maison'
        Tout_pour_bebe = 'Tout pour bébé'
        Animalerie = 'Animalerie'
        Produits_du_monde ='Produits du monde'
        Bio_et_nutrition ='Bio et nutrition'
    
    name = models.CharField(choices=Rayons.choices, max_length=100)
    description = models.TextField(blank=True)
    active = models.BooleanField(default=False)
    shopstores = models.ManyToManyField('store.Store', related_name='categories_in_category', blank=True)  # Relation ManyToMany
 
   
    def __str__(self):
        return self.name

class Product(models.Model):

    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)
    class Name (models.TextChoices) :
        Pommes_de_terre = 'Pommes_de_terre'
        Tomates = 'Tomates'
        Bananes ='Bananes'
        Steaks_haches ='Steaks haches'
        Frites = 'Frites'

    name = models.CharField(choices= Name.choices, max_length=100)
    description = models.TextField(blank=True)
    active = models.BooleanField(default=False)

    category=models.ForeignKey('store.Category', on_delete=models.CASCADE, related_name='products')

    def __str__(self):
        return self.name

class Article(models.Model):

    image=models.ImageField( blank=False, null=False)
    date_created = models.DateTimeField(auto_now_add=True)
    date_updated = models.DateTimeField(auto_now=True)

    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    stock = models.PositiveIntegerField(default=0)
    price = models.DecimalField(max_digits=4, decimal_places=2)
    shopstore=models.ForeignKey('store.Store', on_delete=models.CASCADE, related_name='categories')
    product = models.ForeignKey('store.Product', on_delete=models.CASCADE, related_name='articles')
    is_popular = models.BooleanField(default=False)
    is_seasonal = models.CharField(max_length=20, default="False")
    class Meta:
        ordering = ['-is_popular', 'name']
        indexes = [
            models.Index(fields=['is_seasonal']),
            models.Index(fields=['is_popular']),
        ]
    def __str__(self):
        return f"{self.name} - {self.shopstore.name}-{self.product.name}-{self.price}"
    