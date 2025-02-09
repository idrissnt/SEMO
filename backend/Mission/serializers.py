from rest_framework.serializers import ModelSerializer
from rest_framework import serializers
from .models import Task

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'user', 'assignee', 'is_accepted']
        read_only_fields = ['user', 'is_accepted']
    def validate_when_is(self, value):
        if value < self.instance.created_at:
            raise serializers.ValidationError("La date de fin ne peut pas être antérieure à la date du jour.")
        return value


    def create(self, validated_data):
        return Task.objects.create(**validated_data)

    def update(self, instance, validated_data):
        # Ici, vous pouvez ajouter une logique personnalisée avant de mettre à jour l'instance
        if instance.creator == self.context['request'].user:
            instance.title = validated_data.get('title', instance.title)
            instance.description = validated_data.get('description', instance.description)
            instance.save()
        return instance

    # def update(self, instance, validated_data):
    #     if instance.user == self.context['request'].user:
    #         instance.title = validated_data.get('title', instance.title)
    #         instance.description = validated_data.get('description', instance.description)
    #         instance.save()
    #     return instance



# class Missionserializer(serializers.ModelSerializer) :

#     class Meta:
#         model = Mission
#         fields = ['id', 'title']

# from django.urls import reverse_lazy
# from django.views.generic import UpdateView, DeleteView
# from .models import Mission

# class MissionUpdateView(UpdateView):
#     model = Mission
#     fields = ['titre', 'description', 'date_debut', 'date_fin']
    

# class MissionDeleteView(DeleteView):
#     model = Mission

# from rest_framework import serializers
# from .models import Mission

# class MissionSerializer(ModelSerializer):
#     class Meta:
#         model = Mission
#         fields = '__all__'

#     def validate_date_fin(self, value):
#         if value < self.instance.created_at:
#             raise serializers.ValidationError("La date de fin ne peut pas être antérieure à la date du jour.")
#         return value

#     def update(self, instance, validated_data):
#         # Ici, vous pouvez ajouter une logique personnalisée avant de mettre à jour l'instance
#         instance.titre = validated_data.get('titre', instance.titre)
#         instance.description = validated_data.get('description', instance.description)
#         # ...
#         instance.save()
#         return instance
   