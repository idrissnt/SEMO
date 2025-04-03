from django.core.management.base import BaseCommand
from tasks.infrastructure.django_models.task_orm_models import TaskCategoryTemplateModel
from tasks.domain.models.entities import TaskCategory


class Command(BaseCommand):
    help = 'Populate task categories with predefined templates'

    def handle(self, *args, **options):
        # Define the task categories and their templates
        categories = [
            {
                'category': TaskCategory.HOME_CLEANING.value,
                'name': 'Faire le ménage',
                'description': 'Nettoyage régulier ou grand ménage de votre espace',
                'attribute_templates': [
                    {
                        'name': 'space_size',
                        'question': 'Quelle est la taille de l\'espace à nettoyer ? (Studio, Appartement, Maison)'
                    },
                    {
                        'name': 'cleaning_types',
                        'question': 'Quels types de nettoyage sont nécessaires ? (Poussière, sols, vitres, sanitaires, etc.)'
                    },
                    {
                        'name': 'supplies_provided',
                        'question': 'Fournissez-vous le matériel et les produits de nettoyage ? (Oui / Non)'
                    },
                    {
                        'name': 'frequency',
                        'question': 'À quelle fréquence souhaitez-vous ce service ? (Ponctuel / Régulier)'
                    },
                    {
                        'name': 'address',
                        'question': 'Quelle est votre adresse ou zone d\'intervention ?'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure souhaitez-vous l\'intervention ?'
                    }
                ]
            },
            {
                'category': TaskCategory.IRONING.value,
                'name': 'Repassage de vêtements',
                'description': 'Service de repassage de vêtements à domicile ou avec dépôt/retrait',
                'attribute_templates': [
                    {
                        'name': 'quantity',
                        'question': 'Quelle quantité de vêtements à repasser ? (Petite, Moyenne, Grande quantité)'
                    },
                    {
                        'name': 'equipment_provided',
                        'question': 'Fournissez-vous le fer à repasser et la table ? (Oui / Non)'
                    },
                    {
                        'name': 'service_type',
                        'question': 'Souhaitez-vous un service à domicile ou un dépôt/retrait ?'
                    },
                    {
                        'name': 'date',
                        'question': 'À quelle date souhaitez-vous le service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.DISHWASHING.value,
                'name': 'Faire la vaisselle',
                'description': 'Service de nettoyage de vaisselle à domicile',
                'attribute_templates': [
                    {
                        'name': 'quantity',
                        'question': 'Quelle est la quantité de vaisselle à nettoyer ? (Quelques assiettes / Repas familial / Après une fête)'
                    },
                    {
                        'name': 'supplies_provided',
                        'question': 'Fournissez-vous des produits de nettoyage ? (Oui / Non)'
                    },
                    {
                        'name': 'date',
                        'question': 'À quelle date souhaitez-vous ce service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.FURNITURE_ASSEMBLY.value,
                'name': 'Monter un meuble',
                'description': 'Assemblage de meubles à domicile',
                'attribute_templates': [
                    {
                        'name': 'furniture_type',
                        'question': 'Quel type de meuble faut-il assembler ? (Table, Lit, Armoire, Bureau…)'
                    },
                    {
                        'name': 'furniture_onsite',
                        'question': 'Avez-vous déjà le meuble sur place ? (Oui / Non)'
                    },
                    {
                        'name': 'tools_provided',
                        'question': 'Y a-t-il des outils fournis pour le montage ? (Oui / Non)'
                    },
                    {
                        'name': 'complexity',
                        'question': 'Quelle est la taille ou la complexité du meuble ? (Petite, Moyenne, Grande)'
                    },
                    {
                        'name': 'address',
                        'question': 'Où doit se faire l\'assemblage ? (Adresse)'
                    }
                ]
            },
            {
                'category': TaskCategory.HEAVY_LIFTING.value,
                'name': 'Porter des charges lourdes',
                'description': 'Déplacer des objets encombrants ou lourds',
                'attribute_templates': [
                    {
                        'name': 'objects',
                        'question': 'Quels objets faut-il déplacer ? (Meubles, Électroménager, Autre)'
                    },
                    {
                        'name': 'stairs',
                        'question': 'Y a-t-il des escaliers ou un ascenseur sur place ? (Oui / Non)'
                    },
                    {
                        'name': 'transport_needed',
                        'question': 'Avez-vous besoin d\'un transport en plus du portage ? (Oui / Non)'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure souhaitez-vous ce service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.LAWN_MOWING.value,
                'name': 'Tondre la pelouse',
                'description': 'Entretien du jardin et tonte de pelouse',
                'attribute_templates': [
                    {
                        'name': 'area_size',
                        'question': 'Quelle est la surface du terrain à tondre ? (Petite, Moyenne, Grande)'
                    },
                    {
                        'name': 'mower_available',
                        'question': 'Avez-vous une tondeuse disponible ? (Oui / Non)'
                    },
                    {
                        'name': 'additional_services',
                        'question': 'Y a-t-il d\'autres services souhaités ? (Taille de haie, Désherbage, Nettoyage)'
                    },
                    {
                        'name': 'date',
                        'question': 'À quelle date souhaitez-vous ce service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.PAINTING.value,
                'name': 'Peindre un mur, une pièce ou une façade',
                'description': 'Services de peinture intérieure ou extérieure',
                'attribute_templates': [
                    {
                        'name': 'space',
                        'question': 'Quel espace doit être peint ? (Mur intérieur, Façade extérieure, Meuble)'
                    },
                    {
                        'name': 'area',
                        'question': 'Quelle est la surface approximative à peindre ? (m²)'
                    },
                    {
                        'name': 'supplies_provided',
                        'question': 'Avez-vous déjà la peinture et le matériel ? (Oui / Non)'
                    },
                    {
                        'name': 'preparation',
                        'question': 'Y a-t-il des préparations nécessaires avant la peinture ? (Nettoyage, Ponçage, Sous-couche)'
                    },
                    {
                        'name': 'date',
                        'question': 'À quelle date souhaitez-vous le service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.COOKING.value,
                'name': 'Cuisiner des repas',
                'description': 'Préparation de plats faits maison',
                'attribute_templates': [
                    {
                        'name': 'meal_type',
                        'question': 'Quel type de repas souhaitez-vous ? (Déjeuner, Dîner, Repas de la semaine, Événement)'
                    },
                    {
                        'name': 'people_count',
                        'question': 'Combien de personnes sont à servir ?'
                    },
                    {
                        'name': 'dietary_restrictions',
                        'question': 'Y a-t-il des restrictions alimentaires ou allergies ? (Oui / Non)'
                    },
                    {
                        'name': 'ingredients',
                        'question': 'Fournissez-vous les ingrédients ou faut-il les acheter ?'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure souhaitez-vous ce service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.DOG_WALKING.value,
                'name': 'Promener un chien',
                'description': 'Service de promenade pour chiens',
                'attribute_templates': [
                    {
                        'name': 'dog_info',
                        'question': 'Quelle est la race et la taille du chien ?'
                    },
                    {
                        'name': 'duration',
                        'question': 'Combien de temps doit durer la promenade ? (30 min, 1h, Plus)'
                    },
                    {
                        'name': 'special_instructions',
                        'question': 'Y a-t-il des instructions particulières ? (Ne pas croiser d\'autres chiens, Médicament à donner)'
                    },
                    {
                        'name': 'frequency',
                        'question': 'À quelle fréquence souhaitez-vous ce service ? (Ponctuel / Régulier)'
                    }
                ]
            },
            {
                'category': TaskCategory.PET_SITTING.value,
                'name': 'Garde d\'animaux',
                'description': 'Service de garde d\'animaux à domicile ou chez le pet-sitter',
                'attribute_templates': [
                    {
                        'name': 'animal_type',
                        'question': 'Quel animal doit être gardé ? (Chien, Chat, Autre)'
                    },
                    {
                        'name': 'location',
                        'question': 'Où doit se faire la garde ? (Chez moi, Chez le pet-sitter)'
                    },
                    {
                        'name': 'special_needs',
                        'question': 'Y a-t-il des besoins spécifiques ? (Alimentation, Médicaments, Promenade)'
                    },
                    {
                        'name': 'duration',
                        'question': 'Quelle est la durée de la garde ? (Quelques heures, Journée, Plusieurs jours)'
                    },
                    {
                        'name': 'start_datetime',
                        'question': 'À quelle date et heure commence la garde ?'
                    }
                ]
            },
            {
                'category': TaskCategory.BABYSITTING.value,
                'name': 'Faire du babysitting',
                'description': 'Service de garde d\'enfants à domicile',
                'attribute_templates': [
                    {
                        'name': 'children_count',
                        'question': 'Combien d\'enfants à garder ?'
                    },
                    {
                        'name': 'children_ages',
                        'question': 'Quel âge ont les enfants ?'
                    },
                    {
                        'name': 'duration',
                        'question': 'Quelle est la durée de la garde ? (Quelques heures, Journée, Soirée)'
                    },
                    {
                        'name': 'special_instructions',
                        'question': 'Y a-t-il des instructions particulières ? (Repas, Coucher, Activités)'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure commence la garde ?'
                    }
                ]
            },
            {
                'category': TaskCategory.SCHOOL_PICKUP.value,
                'name': 'Récupérer un enfant après l\'école',
                'description': 'Sortie d\'école & accompagnement',
                'attribute_templates': [
                    {
                        'name': 'school_info',
                        'question': 'Quelle est l\'école et l\'adresse ?'
                    },
                    {
                        'name': 'child_info',
                        'question': 'Prénom, âge et classe de l\'enfant ?'
                    },
                    {
                        'name': 'pickup_time',
                        'question': 'À quelle heure faut-il récupérer l\'enfant ?'
                    },
                    {
                        'name': 'destination',
                        'question': 'Où faut-il emmener l\'enfant après l\'école ?'
                    },
                    {
                        'name': 'frequency',
                        'question': 'À quelle fréquence souhaitez-vous ce service ? (Ponctuel / Régulier)'
                    }
                ]
            },
            {
                'category': TaskCategory.MOVING_HELP.value,
                'name': 'Aider à un déménagement',
                'description': 'Porter, emballer, transporter',
                'attribute_templates': [
                    {
                        'name': 'volume',
                        'question': 'Quel est le volume approximatif à déménager ? (Studio, 2 pièces, Maison...)'
                    },
                    {
                        'name': 'service_needed',
                        'question': 'Quel service précis est nécessaire ? (Emballage, Portage, Transport, Tout)'
                    },
                    {
                        'name': 'addresses',
                        'question': 'Quelles sont les adresses de départ et d\'arrivée ?'
                    },
                    {
                        'name': 'stairs',
                        'question': 'Y a-t-il des escaliers ou un ascenseur ? (Départ et arrivée)'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure souhaitez-vous ce service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.INTERIOR_ORGANIZATION.value,
                'name': 'Aider à un aménagement intérieur',
                'description': 'Déballer, ranger, organiser',
                'attribute_templates': [
                    {
                        'name': 'space_type',
                        'question': 'Quel type d\'espace à organiser ? (Appartement entier, Chambre, Cuisine...)'
                    },
                    {
                        'name': 'service_needed',
                        'question': 'Quel service précis est nécessaire ? (Déballage, Rangement, Organisation)'
                    },
                    {
                        'name': 'duration',
                        'question': 'Combien de temps estimez-vous nécessaire pour cette tâche ?'
                    },
                    {
                        'name': 'address',
                        'question': 'À quelle adresse se trouve le lieu à organiser ?'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure souhaitez-vous ce service ?'
                    }
                ]
            },
            {
                'category': TaskCategory.QUEUE_WAITING.value,
                'name': 'Rester dans une file d\'attente',
                'description': 'Faire la queue à votre place',
                'attribute_templates': [
                    {
                        'name': 'location',
                        'question': 'Où se trouve la file d\'attente ? (Adresse précise)'
                    },
                    {
                        'name': 'purpose',
                        'question': 'Quel est l\'objectif de cette file d\'attente ? (Billet, Administration, Autre)'
                    },
                    {
                        'name': 'estimated_time',
                        'question': 'Combien de temps estimez-vous que la file d\'attente va durer ?'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure faut-il commencer à faire la queue ?'
                    }
                ]
            },
            {
                'category': TaskCategory.WEDDING_HELP.value,
                'name': 'Aider à organiser un mariage',
                'description': 'Assistance pour l\'organisation d\'un mariage',
                'attribute_templates': [
                    {
                        'name': 'wedding_date',
                        'question': 'Quelle est la date prévue du mariage ?'
                    },
                    {
                        'name': 'guests_count',
                        'question': 'Combien d\'invités sont prévus ?'
                    },
                    {
                        'name': 'help_needed',
                        'question': 'Quel type d\'aide précise recherchez-vous ? (Planification, Décoration, Coordination jour J)'
                    },
                    {
                        'name': 'budget',
                        'question': 'Quel est votre budget pour cette assistance ?'
                    },
                    {
                        'name': 'location',
                        'question': 'Où se déroulera le mariage ?'
                    }
                ]
            },
            {
                'category': TaskCategory.EVENT_ORGANIZATION.value,
                'name': 'Aider à organiser un anniversaire ou un événement',
                'description': 'Assistance pour l\'organisation d\'événements',
                'attribute_templates': [
                    {
                        'name': 'event_type',
                        'question': 'Quel type d\'événement ? (Anniversaire, Fête, Autre)'
                    },
                    {
                        'name': 'event_date',
                        'question': 'Quelle est la date prévue de l\'événement ?'
                    },
                    {
                        'name': 'guests_count',
                        'question': 'Combien d\'invités sont prévus ?'
                    },
                    {
                        'name': 'help_needed',
                        'question': 'Quel type d\'aide précise recherchez-vous ? (Planification, Décoration, Animation)'
                    },
                    {
                        'name': 'location',
                        'question': 'Où se déroulera l\'événement ?'
                    }
                ]
            },
            {
                'category': TaskCategory.PHOTOGRAPHY_FINDING.value,
                'name': 'Trouver un photographe',
                'description': 'Recherche et mise en relation avec un photographe professionnel',
                'attribute_templates': [
                    {
                        'name': 'event_type',
                        'question': 'Pour quel type d\'événement ? (Mariage, Portrait, Entreprise, Autre)'
                    },
                    {
                        'name': 'style',
                        'question': 'Quel style de photographie recherchez-vous ?'
                    },
                    {
                        'name': 'budget',
                        'question': 'Quel est votre budget pour ce service ?'
                    },
                    {
                        'name': 'date',
                        'question': 'À quelle date avez-vous besoin du photographe ?'
                    },
                    {
                        'name': 'location',
                        'question': 'Où se déroulera la séance photo ?'
                    }
                ]
            },
            {
                'category': TaskCategory.VIDEOGRAPHY_FINDING.value,
                'name': 'Trouver un vidéaste',
                'description': 'Recherche et mise en relation avec un vidéaste professionnel',
                'attribute_templates': [
                    {
                        'name': 'event_type',
                        'question': 'Pour quel type d\'événement ? (Mariage, Entreprise, Clip, Autre)'
                    },
                    {
                        'name': 'style',
                        'question': 'Quel style de vidéo recherchez-vous ?'
                    },
                    {
                        'name': 'budget',
                        'question': 'Quel est votre budget pour ce service ?'
                    },
                    {
                        'name': 'date',
                        'question': 'À quelle date avez-vous besoin du vidéaste ?'
                    },
                    {
                        'name': 'location',
                        'question': 'Où se déroulera le tournage ?'
                    }
                ]
            },
            {
                'category': TaskCategory.APPLIANCE_REPAIR.value,
                'name': 'Installer ou réparer une machine à laver',
                'description': 'Installation ou réparation d\'appareils électroménagers',
                'attribute_templates': [
                    {
                        'name': 'service_type',
                        'question': 'S\'agit-il d\'une installation ou d\'une réparation ?'
                    },
                    {
                        'name': 'appliance_type',
                        'question': 'Quel type d\'appareil ? (Machine à laver, Lave-vaisselle, Autre)'
                    },
                    {
                        'name': 'brand_model',
                        'question': 'Quelle est la marque et le modèle de l\'appareil ?'
                    },
                    {
                        'name': 'issue',
                        'question': 'Si réparation, quel est le problème rencontré ?'
                    },
                    {
                        'name': 'address',
                        'question': 'À quelle adresse se trouve l\'appareil ?'
                    },
                    {
                        'name': 'datetime',
                        'question': 'À quelle date et heure souhaitez-vous ce service ?'
                    }
                ]
            }
        ]
        
        # Create the templates
        count = 0
        for category_data in categories:
            # Check if the category already exists
            existing = TaskCategoryTemplateModel.objects.filter(category=category_data['category']).first()
            if existing:
                self.stdout.write(self.style.WARNING(f"Category {category_data['name']} already exists, skipping"))
                continue
                
            # Create the category template
            TaskCategoryTemplateModel.objects.create(
                category=category_data['category'],
                name=category_data['name'],
                description=category_data['description'],
                attribute_templates=category_data['attribute_templates']
            )
            count += 1
            
        self.stdout.write(self.style.SUCCESS(f'Successfully created {count} task category templates'))
