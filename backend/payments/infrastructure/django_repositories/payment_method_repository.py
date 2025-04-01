"""
Django ORM implementation of the payment method repository interface.

This module provides a concrete implementation of the payment method repository
interface using Django's ORM for data access.
"""

from typing import List, Optional
from uuid import UUID
from django.db import transaction
from django.conf import settings

from payments.domain.models.entities import PaymentMethod
from payments.domain.repositories.payment_method_repository_interfaces import PaymentMethodRepository
from payments.infrastructure.django_models.orm_models import PaymentMethodModel


class DjangoPaymentMethodRepository(PaymentMethodRepository):
    """Django ORM implementation of PaymentMethodRepository
    
    This class provides a concrete implementation of the payment method repository
    interface using Django's ORM for data access. It handles the conversion
    between domain entities and ORM models.
    """
    
    def create(self, payment_method: PaymentMethod) -> PaymentMethod:

        # If this is the default payment method, unset any existing default
        if payment_method.is_default:
            with transaction.atomic():
                PaymentMethodModel.objects.filter(
                    user_id=payment_method.user_id,
                    is_default=True
                ).update(is_default=False)
                
                payment_method_model = PaymentMethodModel(
                    id=payment_method.id,
                    user_id=payment_method.user_id,
                    type=payment_method.type,
                    is_default=True,
                    last_four=payment_method.last_four,
                    expiry_month=payment_method.expiry_month,
                    expiry_year=payment_method.expiry_year,
                    card_brand=payment_method.card_brand,
                    external_customer_id=payment_method.external_customer_id
                )
                
                if payment_method.billing_details:
                    payment_method_model.billing_details = payment_method.billing_details
                    
                payment_method_model.save()
        else:
            payment_method_model = PaymentMethodModel(
                id=payment_method.id,
                user_id=payment_method.user_id,
                type=payment_method.type,
                is_default=payment_method.is_default,
                last_four=payment_method.last_four,
                expiry_month=payment_method.expiry_month,
                expiry_year=payment_method.expiry_year,
                card_brand=payment_method.card_brand,
                external_customer_id=payment_method.external_customer_id
            )
            
            if payment_method.billing_details:
                payment_method_model.billing_details = payment_method.billing_details
                
            payment_method_model.save()
            
        return self._to_domain_entity(payment_method_model)
    
    def get_by_id(self, payment_method_id: str) -> Optional[PaymentMethod]:
        try:
            payment_method_model = PaymentMethodModel.objects.get(id=payment_method_id)
            return self._to_domain_entity(payment_method_model)
        except PaymentMethodModel.DoesNotExist:
            return None
    
    def get_by_user_id(self, user_id: UUID) -> List[PaymentMethod]:
        payment_method_models = PaymentMethodModel.objects.filter(user_id=user_id)
        return [self._to_domain_entity(model) for model in payment_method_models]
    
    def get_default_for_user(self, user_id: UUID) -> Optional[PaymentMethod]:
        try:
            payment_method_model = PaymentMethodModel.objects.get(
                user_id=user_id,
                is_default=True
            )
            return self._to_domain_entity(payment_method_model)
        except PaymentMethodModel.DoesNotExist:
            return None
    
    def update(self, payment_method: PaymentMethod) -> PaymentMethod:

        try:
            payment_method_model = PaymentMethodModel.objects.get(id=payment_method.id)
            
            # If setting as default, unset any existing default
            if payment_method.is_default and not payment_method_model.is_default:
                with transaction.atomic():
                    PaymentMethodModel.objects.filter(
                        user_id=payment_method.user_id,
                        is_default=True
                    ).update(is_default=False)
                    
                    payment_method_model.type = payment_method.type
                    payment_method_model.is_default = True
                    payment_method_model.last_four = payment_method.last_four
                    payment_method_model.expiry_month = payment_method.expiry_month
                    payment_method_model.expiry_year = payment_method.expiry_year
                    payment_method_model.card_brand = payment_method.card_brand
                    payment_method_model.external_customer_id = payment_method.external_customer_id
                    
                    if payment_method.billing_details:
                        payment_method_model.billing_details = payment_method.billing_details
                        
                    payment_method_model.save()
            else:
                payment_method_model.type = payment_method.type
                payment_method_model.is_default = payment_method.is_default
                payment_method_model.last_four = payment_method.last_four
                payment_method_model.expiry_month = payment_method.expiry_month
                payment_method_model.expiry_year = payment_method.expiry_year
                payment_method_model.card_brand = payment_method.card_brand
                payment_method_model.external_customer_id = payment_method.external_customer_id
                
                if payment_method.billing_details:
                    payment_method_model.billing_details = payment_method.billing_details
                    
                payment_method_model.save()
                
            return self._to_domain_entity(payment_method_model)
        except PaymentMethodModel.DoesNotExist:
            raise ValueError(f"Payment method with ID {payment_method.id} does not exist")
    
    def delete(self, payment_method_id: str) -> bool:

        try:
            payment_method_model = PaymentMethodModel.objects.get(id=payment_method_id)
            was_default = payment_method_model.is_default
            user_id = payment_method_model.user_id
            
            payment_method_model.delete()
            
            # If this was the default, set another one as default if available
            if was_default:
                another_payment_method = PaymentMethodModel.objects.filter(
                    user_id=user_id
                ).first()
                
                if another_payment_method:
                    another_payment_method.is_default = True
                    another_payment_method.save()
                    
            return True
        except PaymentMethodModel.DoesNotExist:
            return False
    
    def set_default(self, user_id: UUID, payment_method_id: str) -> bool:
        try:
            with transaction.atomic():
                # Unset any existing default
                PaymentMethodModel.objects.filter(
                    user_id=user_id,
                    is_default=True
                ).update(is_default=False)
                
                # Set the new default
                payment_method_model = PaymentMethodModel.objects.get(
                    id=payment_method_id,
                    user_id=user_id
                )
                payment_method_model.is_default = True
                payment_method_model.save()
                
                return True
        except PaymentMethodModel.DoesNotExist:
            return False
        
    def get_or_create_customer_id(self, user_id: UUID) -> str:

        # Check if any payment method already has a customer ID
        existing_method = PaymentMethodModel.objects.filter(
            user_id=user_id,
            external_customer_id__isnull=False
        ).first()
        
        if existing_method and existing_method.external_customer_id:
            return existing_method.external_customer_id
            
        # If no customer ID is found, we should raise an error since the repository
        # should not be responsible for creating customers in the external service
        raise ValueError(f"No customer ID found for user {user_id}. This should be handled by the payment service.")

    def _to_domain_entity(self, model: PaymentMethodModel) -> PaymentMethod:

        return PaymentMethod(
            id=model.id,
            user_id=model.user.id,
            type=model.type,
            is_default=model.is_default,
            last_four=model.last_four,
            expiry_month=model.expiry_month,
            expiry_year=model.expiry_year,
            card_brand=model.card_brand,
            external_id=model.id,
            external_customer_id=model.external_customer_id,
            billing_details=model.billing_details
        )    

