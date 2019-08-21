module Workarea
  module Paypal
    class Update
      attr_reader :order, :payment, :shipping, :token

      def initialize(order, payment, shipping, token)
        @order = order
        @payment = payment
        @shipping = shipping
        @token = token
      end

      def details
        @details ||= Workarea::Paypal.gateway.details_for(token)
      end

      def apply
        order.email ||= details.email
        set_shipping_address(details.params)
        set_shipping_service
        set_billing_address(details.params)

        payment.clear_credit_card
        payment.set_paypal(
          token:    details.token,
          payer_id: details.payer_id,
          details:  details.params
        )

        Pricing.perform(order, shipping)
        payment.adjust_tender_amounts(order.total_price)
      end

      private

      def set_shipping_address(params)
        shipping.set_address(
          first_name: params['first_name'],
          last_name: params['last_name'],
          street: params['PaymentDetails']['ShipToAddress']['Street1'],
          street_2: params['PaymentDetails']['ShipToAddress']['Street2'],
          city: params['PaymentDetails']['ShipToAddress']['CityName'],
          region: params['PaymentDetails']['ShipToAddress']['StateOrProvince'],
          postal_code: params['PaymentDetails']['ShipToAddress']['PostalCode'],
          country: params['PaymentDetails']['ShipToAddress']['Country'],
          phone_number: params['PaymentDetails']['ShipToAddress']['Phone']
        )
      end

      def set_billing_address(params)
        payment.set_address(
          first_name:   params['PayerInfo']['PayerName']['FirstName'],
          last_name:    params['PayerInfo']['PayerName']['LastName'],
          street:       params['PayerInfo']['Address']['Street1'],
          street_2:     params['PayerInfo']['Address']['Street2'],
          city:         params['PayerInfo']['Address']['CityName'],
          region:       params['PayerInfo']['Address']['StateOrProvince'],
          postal_code:  params['PayerInfo']['Address']['PostalCode'],
          country:      params['PayerInfo']['Address']['Country'],
          phone_number: params['PayerInfo']['Address']['Phone']
        )
      end

      def set_shipping_service
        Checkout::Steps::Shipping.new(self).update({})
      end
    end
  end
end
