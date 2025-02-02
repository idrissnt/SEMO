from django.db import models
from store.models import Article


class Cart(models.Model):
    # user = models.OneToOneField(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return f"Cart {self.id} created at {self.created_at}"
    
class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name='items')
    article = models.ForeignKey(Article, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    sous_total = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    total = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)

    def update_totals(self):
        # Calculez le sous_total en fonction des articles dans le panier
        self.sous_total = sum(item.article.price * item.quantity for item in self.cartitem_set.all())
        self.total = self.sous_total + 3  # Ajoutez les frais de livraison ou autres frais
        self.save()
    def __str__(self):
        return f"{self.quantity} of {self.article.name} in Cart {self.cart.id}"
    

