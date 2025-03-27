# from django.core.management.base import BaseCommand
# import logging

# from cart.infrastructure.factory import CartFactory

# logger = logging.getLogger(__name__)

# class Command(BaseCommand):
#     help = 'Process abandoned cart recoveries and send recovery emails'

#     def handle(self, *args, **options):
#         self.stdout.write('Starting cart recovery processing...')
        
#         # Create recovery service using the factory
#         recovery_service = CartFactory.create_cart_recovery_service()
        
#         # Process pending recoveries
#         total, successful = recovery_service.process_pending_recoveries()
        
#         self.stdout.write(
#             self.style.SUCCESS(
#                 f'Successfully processed {total} cart recoveries with {successful} emails sent'
#             )
#         )
