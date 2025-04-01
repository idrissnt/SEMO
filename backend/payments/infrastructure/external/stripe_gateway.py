"""
Stripe gateway for handling all Stripe API interactions.
This isolates external service dependencies from the rest of the application.
"""
import stripe
from typing import Dict, Any, Optional
from django.conf import settings


class StripeGateway:
    """Gateway for Stripe API interactions"""
    
    def __init__(self):
        stripe.api_key = settings.STRIPE_SECRET_KEY
    
    def create_payment_intent(self, amount: float, currency: str, 
                             customer_id: Optional[str] = None,
                             payment_method_id: Optional[str] = None,
                             setup_future_usage: Optional[str] = None,
                             metadata: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Create a payment intent in Stripe"""
        params = {
            'amount': int(amount * 100),  # Convert to cents
            'currency': currency,
            'confirm': False,
            'metadata': metadata or {}
        }
        
        if customer_id:
            params['customer'] = customer_id
            
        if payment_method_id:
            params['payment_method'] = payment_method_id
            params['confirmation_method'] = 'manual'
            
        if setup_future_usage:
            params['setup_future_usage'] = setup_future_usage
            
        try:
            intent = stripe.PaymentIntent.create(**params)
            return {
                'success': True,
                'payment_intent_id': intent.id,
                'client_secret': intent.client_secret,
                'status': intent.status
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def confirm_payment_intent(self, payment_intent_id: str) -> Dict[str, Any]:
        """Confirm a payment intent in Stripe"""
        try:
            intent = stripe.PaymentIntent.confirm(payment_intent_id)
            return {
                'success': True,
                'payment_intent_id': intent.id,
                'status': intent.status,
                'requires_action': intent.status == 'requires_action',
                'client_secret': intent.client_secret
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def retrieve_payment_intent(self, payment_intent_id: str) -> Dict[str, Any]:
        """Retrieve a payment intent from Stripe"""
        try:
            intent = stripe.PaymentIntent.retrieve(payment_intent_id)
            return {
                'success': True,
                'payment_intent_id': intent.id,
                'status': intent.status,
                'amount': intent.amount / 100,  # Convert from cents
                'currency': intent.currency,
                'payment_method_id': intent.payment_method
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def create_setup_intent(self, customer_id: Optional[str] = None,
                           payment_method_id: Optional[str] = None) -> Dict[str, Any]:
        """Create a setup intent in Stripe"""
        params = {}
        
        if customer_id:
            params['customer'] = customer_id
            
        if payment_method_id:
            params['payment_method'] = payment_method_id
            
        try:
            intent = stripe.SetupIntent.create(**params)
            return {
                'success': True,
                'setup_intent_id': intent.id,
                'client_secret': intent.client_secret,
                'status': intent.status
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def confirm_setup_intent(self, setup_intent_id: str) -> Dict[str, Any]:
        """Confirm a setup intent in Stripe"""
        try:
            intent = stripe.SetupIntent.confirm(setup_intent_id)
            return {
                'success': True,
                'setup_intent_id': intent.id,
                'status': intent.status,
                'payment_method_id': intent.payment_method
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def retrieve_payment_method(self, payment_method_id: str) -> Dict[str, Any]:
        """Retrieve a payment method from Stripe"""
        try:
            method = stripe.PaymentMethod.retrieve(payment_method_id)
            
            result = {
                'success': True,
                'id': method.id,
                'type': method.type,
                'billing_details': method.billing_details
            }
            
            # Extract card details if available
            if method.type == 'card' and hasattr(method, 'card'):
                result.update({
                    'last_four': method.card.last4,
                    'expiry_month': method.card.exp_month,
                    'expiry_year': method.card.exp_year,
                    'card_brand': method.card.brand
                })
                
            return result
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def create_customer(self, email: Optional[str] = None, name: Optional[str] = None, user_id: Optional[str] = None) -> str:
        """Create a customer in Stripe
        
        Args:
            email: Optional email for the customer
            name: Optional name for the customer
            user_id: Optional user ID to store in metadata
            
        Returns:
            The Stripe customer ID
            
        Raises:
            stripe.error.StripeError: If the customer creation fails
        """
        params = {}
        
        if email:
            params['email'] = email
        
        if name:
            params['name'] = name
            
        if user_id:
            params['metadata'] = {'user_id': user_id}
            
        try:
            customer = stripe.Customer.create(**params)
            return customer.id
        except stripe.error.StripeError as e:
            raise e
    
    def attach_payment_method_to_customer(self, payment_method_id: str, 
                                         customer_id: str) -> Dict[str, Any]:
        """Attach a payment method to a customer in Stripe"""
        try:
            payment_method = stripe.PaymentMethod.attach(
                payment_method_id,
                customer=customer_id
            )
            return {
                'success': True,
                'payment_method_id': payment_method.id
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
    
    def detach_payment_method(self, payment_method_id: str) -> Dict[str, Any]:
        """Detach a payment method from a customer in Stripe"""
        try:
            payment_method = stripe.PaymentMethod.detach(payment_method_id)
            return {
                'success': True,
                'payment_method_id': payment_method.id
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
            
    def create_refund(self, payment_intent_id: str, amount: Optional[float] = None) -> Dict[str, Any]:
        """Create a refund for a payment intent in Stripe"""
        try:
            params = {
                'payment_intent': payment_intent_id
            }
            
            if amount is not None:
                params['amount'] = int(amount * 100)  # Convert to cents
                
            refund = stripe.Refund.create(**params)
            
            return {
                'success': True,
                'refund_id': refund.id,
                'status': refund.status,
                'amount': refund.amount / 100 if refund.amount else None  # Convert from cents
            }
        except stripe.error.StripeError as e:
            return {
                'success': False,
                'error': str(e)
            }
