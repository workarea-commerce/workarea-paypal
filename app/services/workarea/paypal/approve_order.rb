module Workarea
  module Paypal
    class ApproveOrder
      delegate :order, :payment, :shippings, :shipping, to: :@checkout
      delegate :payer, :status, :purchase_units, :payment_source, to: :paypal_order

      def initialize(checkout, paypal_id)
        @checkout = checkout
        @paypal_id = paypal_id
      end

      def paypal_order
        @paypal_order ||= Workarea::Paypal.gateway.get_order(@paypal_id).result
      end

      # As of this writing, PayPal only ever allows one purchase unit.
      #
      def details
        purchase_units.first
      end

      def perform
        order.email ||= payer&.email_address

        set_shipping_address
        set_shipping_service
        set_billing_address

        payment.clear_credit_card
        payment.set_paypal(
          direct_payment_details.reverse_merge(
            paypal_id: @paypal_id,
            approved: true, #approved?
            payer_id: payer&.payer_id,
            details:  Paypal.transform_values(paypal_order)
          )
        )

        Pricing.perform(order, shippings)
        payment.adjust_tender_amounts(order.total_price)
      end

      def approved?
        status == 'APPROVED' || direct_payment?
      end

      private

      def set_shipping_address
        name = details.shipping.name.full_name.split(' ')

        shipping.set_address(
          first_name:   name.shift,
          last_name:    name.join(' '),
          street:       details.shipping.address.address_line_1,
          street_2:     details.shipping.address.address_line_2,
          city:         details.shipping.address.admin_area_2,
          region:       details.shipping.address.admin_area_1,
          postal_code:  details.shipping.address.postal_code,
          country:      details.shipping.address.country_code,
          phone_number: payer&.phone&.phone_number&.national_number
        )
      end

      def set_billing_address
        return unless payer.present? && payer&.address&.address_line_1.present?

        payment.set_address(
          first_name:   payer.name&.given_name,
          last_name:    payer.name&.surname,
          street:       payer.address.address_line_1,
          street_2:     payer.address.address_line_2,
          city:         payer.address.admin_area_2,
          region:       payer.address.admin_area_1,
          postal_code:  payer.address.postal_code,
          country:      payer.address.country_code,
          phone_number: payer.phone&.phone_number&.national_number
        )
      end

      def set_shipping_service
        Checkout::Steps::Shipping.new(self).update({})
      end

      def direct_payment?
        payment_source&.card.present?
      end

      def direct_payment_details
        return {} unless direct_payment?

        {
          details:  {
            display_number: ActiveMerchant::Billing::CreditCard.mask(
              payment_source.card.last_digits
            ),
            issuer: payment_source.card.brand
          },
          direct_payment: true
        }
      end
    end
  end
end
