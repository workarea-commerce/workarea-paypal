module Workarea
  module Paypal
    class CreateOrder
      delegate :order, :user, :payment, :shippings, :shipping, to: :@checkout

      def initialize(checkout)
        @checkout = checkout
      end

      def perform
        Pricing.perform(order, shippings)
        Paypal.gateway.create_order(body: request_body)
      end

      def request_body
        {
          intent: 'CAPTURE',
          application_context: {
            brand_name: Workarea.config.site_name,
            locale: I18n.locale,
            landing_page: 'BILLING',
            shipping_preference: shipping_preference,
            user_action: 'CONTINUE'
          },
          payer: payer,
          purchase_units: [{
            custom_id: order.id,
            amount: amount,
            items: items,
            shipping: shipping_info
          }]
        }
      end

      def payer
        return {} unless order.email.present?

        info = { email_address: order.email }.compact
        return info unless payment.address&.persisted?

        info[:name] = {
          given_name: payment.address.first_name,
          surname: payment.address.last_name,
        }

        info[:address] = {
          address_line_1: payment.address.street,
          address_line_2: payment.address.street_2,
          admin_area_2: payment.address.city,
          admin_area_1: payment.address.region,
          postal_code: payment.address.postal_code,
          country_code: payment.address.country.alpha2
        }

        return info unless payment.address.phone_number.present?

        info['phone'] = {
          phone_type: 'HOME',
          phone_number: {
            national_number: payment.address.phone_number
          }
        }

        info
      end

      def amount
        {
          currency_code: currency_code,
          value: (order.total_price - other_tenders_total).to_s,
          breakdown: {
            item_total: {
              currency_code: currency_code,
              value: order.subtotal_price.to_s
            },
            shipping: {
              currency_code: currency_code,
              value: order.shipping_total.to_s
            },
            tax_total: {
              currency_code: currency_code,
              value: order.tax_total.to_s
            },
            discount: {
              currency_code: currency_code,
              value: (discount_total.abs + other_tenders_total).to_s
            },
            shipping_discount: {
              currency_code: currency_code,
              value: shipping_discount_total.abs.to_s
            }
          }
        }
      end

      def items
        order.items.map do |item|
          view_model = Storefront::OrderItemViewModel.wrap(item)

          {
            name: view_model.product_name,
            description: view_model.details.values.join(' '),
            sku: item.sku,
            unit_amount: {
              currency_code: currency_code,
              value: item.current_unit_price.to_s
            },
            quantity: item.quantity,
            category: item.fulfilled_by?(:shipping) ? 'PHYSICAL_GOODS' : 'DIGITAL_GOODS'
          }
        end
      end

      def shipping_info
        return {} unless send_shipping_info?

        {
          method: shipping.shipping_service&.name,
          name: {
            full_name: [
              shipping.address.first_name,
              shipping.address.last_name
            ].compact.join(' ')
          },
          address: {
            address_line_1: shipping.address.street,
            address_line_2: shipping.address.street_2,
            admin_area_2: shipping.address.city,
            admin_area_1: shipping.address.region,
            postal_code: shipping.address.postal_code,
            country_code: shipping.address.country.alpha2
          }
        }
      end

      def send_shipping_info?
        order.requires_shipping? &&
          shippings.one? &&
          shipping.shippable?
      end

      private

      def currency_code
        order.total_price.currency.iso_code
      end

      def shipping_preference
        if send_shipping_info?
          'SET_PROVIDED_ADDRESS' # Shows addressed provided on PayPal pages
        elsif order.requires_shipping? && !shipping&.shippable?
          'GET_FROM_FILE' # Uses customer address from PayPal
        else
          'NO_SHIPPING' # Hides shipping on PayPal pages
        end
      end

      def price_adjustments
        @price_adjustments ||=
          order.price_adjustments +
            shippings.map(&:price_adjustments).reduce(:+)
      end

      def discount_total
        price_adjustments.adjusting('order').discounts.sum(&:amount)
      end

      def other_tenders_total
        payment.tenders.reject { |t| t.slug == :paypal }.sum(&:amount).to_m
      end

      def shipping_discount_total
        price_adjustments.adjusting('shipping').discounts.sum(&:amount)
      end
    end
  end
end
