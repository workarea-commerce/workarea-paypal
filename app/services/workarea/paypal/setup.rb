module Workarea
  module Paypal
    class Setup
      attr_reader :order, :user, :shipping, :context
      delegate :request, to: :context
      delegate :gateway, to: Workarea::Paypal

      def initialize(order, user, shipping, context)
        @order = order
        @user = user
        @shipping = shipping
        @context = context
      end

      def paypal_response
        @paypal_response ||= gateway.setup_authorization(
          order.total_price.cents,
          ip:                request.remote_ip,
          return_url:        context.complete_paypal_url(order.id),
          cancel_return_url: context.cart_url,
          currency:          order.total_price.currency,
          subtotal:          subtotal,
          shipping:          order.shipping_total.cents,
          handling:          0,
          tax:               order.tax_total.cents,
          items:             items,
          shipping_address:  shipping_address,
          order_id:          order.id
        )
      end

      def items
        order_items + item_level_discounts + order_level_discounts
      end

      def subtotal
        order.subtotal_price.cents +
          order.price_adjustments.adjusting('order').discounts.sum.cents
      end

      def shipping_address
        serialize_address(shipping.try(:address) || user.try(:default_shipping_address))
      end

      def token
        paypal_response.token
      end

      def redirect_url
        gateway.redirect_url_for(token)
      end

      private

      def serialize_address(address)
        return {} unless address

        name = "#{address.first_name} #{address.last_name}"
        phone = [address.phone_number, address.phone_extension].reject(&:blank?).join(' x')

        { name:     name,
          address1: address.street,
          address2: address.street_2,
          city:     address.city,
          state:    address.region,
          country:  address.country,
          zip:      address.postal_code,
          phone:    phone }
      end

      def order_items
        order.items.map do |item|
          item_discount_total = item.price_adjustments.discounts.sum.cents

          {
            name: item.product_attributes.with_indifferent_access[:name],
            quantity: item.quantity,
            amount: (item.total_price.cents - item_discount_total) / item.quantity
          }
        end
      end

      def item_level_discounts
        order_items_with_discounts = order.items.select do |item|
          item.price_adjustments.discounts.present?
        end

        order_items_with_discounts.flat_map do |item|
          item.price_adjustments.discounts.map do |discount|
            {
              name: discount.description.titleize,
              quantity: 1,
              amount: discount.amount.cents
            }
          end
        end
      end

      def order_level_discounts
        order
          .price_adjustments
          .adjusting('order')
          .discounts
          .map do |discount|
            {
              name: discount.description.titleize,
              quantity: 1,
              amount: discount.amount.cents
            }
          end
      end
    end
  end
end
