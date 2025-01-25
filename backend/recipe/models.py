from django.db import models
from product.models import Product

# Create your models here.

class Recipe(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    image_url = models.ImageField(null=True, blank=True, default='images/recipes/pate_carbo.png')
    preparation_time = models.IntegerField(help_text='Time in minutes')
    cooking_time = models.IntegerField(help_text='Time in minutes')
    servings = models.IntegerField()
    difficulty = models.CharField(max_length=20, choices=[
        ('EASY', 'Easy'),
        ('MEDIUM', 'Medium'),
        ('HARD', 'Hard')
    ])
    ingredients = models.ManyToManyField(Product, related_name='recipes')
    instructions = models.TextField()
    is_popular = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-is_popular', 'name']
        indexes = [
            models.Index(fields=['is_popular']),
            models.Index(fields=['difficulty']),
        ]

    def __str__(self):
        return self.name
